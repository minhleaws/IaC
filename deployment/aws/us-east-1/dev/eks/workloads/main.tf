terraform {
  backend "s3" {
    bucket = "minhleaws-terraform-backend-185078133150"
    # The key definition changes following the environment
    key    = "deployment/aws/us-east-1/dev/eks/workloads.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "eks_cluster" {
  backend = "s3"

  config = {
    bucket = "minhleaws-terraform-backend-185078133150"
    # The key definition changes following the environment
    key    = "deployment/aws/us-east-1/dev/eks/cluster.tfstate"
    region = "us-east-1"
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks_cluster.outputs.eks_cluster_id
}

locals {
  name_prefix = "minhleaws-dev"
  common_tags = {
    env    = "dev",
    tenant = "minhleaws"
  }
  region = "us-east-1"
}

provider "aws" {
  region = local.region
}


## SOURCE: https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
## CREATE SERVICE ACCOUNT
module "aws_lb_controller_iam_role_policy" {
  source = "../../../../../../modules/aws/eks-service-account"

  openid_connect_provider_url = data.terraform_remote_state.eks_cluster.outputs.openid_connect_provider_url
  openid_connect_provider_arn = data.terraform_remote_state.eks_cluster.outputs.openid_connect_provider_arn
  iam_role_name               = "AmazonEKSLoadBalancerControllerRole"
  iam_policy_name             = "AWSLoadBalancerControllerIAMPolicy"
  policy                      = file("policies/aws-lb-controller.json")
  cluster                     = data.terraform_remote_state.eks_cluster.outputs.eks_cluster_id
  namespace                   = "kube-system"
  service_account             = "aws-load-balancer-controller"
}

module "foo_iam_role_policy" {
  source = "../../../../../../modules/aws/eks-service-account"

  openid_connect_provider_url = data.terraform_remote_state.eks_cluster.outputs.openid_connect_provider_url
  openid_connect_provider_arn = data.terraform_remote_state.eks_cluster.outputs.openid_connect_provider_arn
  iam_role_name               = "${local.name_prefix}-app-role"
  iam_policy_name             = "${local.name_prefix}-app-policy"
  policy                      = file("policies/app.json")
  cluster                     = data.terraform_remote_state.eks_cluster.outputs.eks_cluster_id
  namespace                   = "foo"
  service_account             = "foo-sa"
}
