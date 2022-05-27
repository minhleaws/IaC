terraform {
  backend "s3" {
    bucket = "minhleaws-terraform-backend-185078133150"
    # The key definition changes following the environment
    key    = "deployment/aws/us-east-1/dev/eks/cluster.tfstate"
    region = "us-east-1"
  }
}


data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "minhleaws-terraform-backend-185078133150"
    # The key definition changes following the environment
    key    = "deployment/aws/us-east-1/dev/network.tfstate"
    region = "us-east-1"
  }
}


locals {
  region           = "us-east-1"
  name_prefix      = "minhleaws-dev"
  eks_cluster_name = "${local.name_prefix}-eks-cluster"
  common_tags = {
    env    = "dev"
    tenant = "minhleaws"
  }
}

provider "aws" {
  region = local.region
}

## CREATE EKS CLUSTER SG
## Security groups control communications within the Amazon EKS cluster including between the managed Kubernetes control plane
## and compute resources in your AWS account such as worker nodes and Fargate pods.
module "eks_cluster_additional_sg" {
  source = "../../../../../../modules/aws/security-group"

  vpc_id              = data.terraform_remote_state.network.outputs.vpc_id
  security_group_name = "${local.name_prefix}-eks-cluster-additional-sg"
  description         = "EKS Cluster Additional SG"
  ingress_rules = [
    {
      id          = 1
      description = "Allow All"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 0
      to_port     = 0
    }
  ]
  egress_rules = [
    {
      id          = 1
      description = "Allow All"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 0
      to_port     = 0
    }
  ]
}

## CREATE EKS CLUSTER IAM ROLE
##  IAM Role to allow the Kubernetes control plane to manage AWS resources on your behalf.
module "eks_cluster_iam_role" {
  source          = "../../../../../../modules/aws/iam-role-policy"
  iam_role_name   = "${local.name_prefix}-AWSEKSClusterRole"
  iam_policy_name = "${local.name_prefix}-AWSEKSClusterRole-policy"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "eks.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )

  ## Add AWS managed policies for Amazon Elastic Kubernetes Service
  aws_managed_policy_arns = [
    # https://docs.aws.amazon.com/eks/latest/userguide/security-iam-awsmanpol.html#security-iam-awsmanpol-AmazonEKSClusterPolicy
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    # Allows Amazon EKS to create and manage the necessary resources to operate Amazon EKS clusters
    # https://docs.aws.amazon.com/eks/latest/userguide/security-iam-awsmanpol.html
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    # Enable Security Groups for Pods (only for EC2 NodeGroup)
    # https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ]

  policies = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [{
        "Sid" : "KMSEncryptDecrypt"
        "Effect" : "Allow",
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }]
    }
  )
}

## CREATE KMS CMK
data "aws_caller_identity" "current" {}

module "eks_kms_cmk" {
  source = "../../../../../../modules/aws/kms"

  alias = "alias/${local.name_prefix}-eks"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Id" : "KMSPolicy",
      "Statement" : [
        {
          "Sid" : "Enable IAM User Permissions",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          },
          "Action" : "kms:*",
          "Resource" : "*"
        }
      ]
    }
  )

  common_tags = local.common_tags
}

## CREATE EKS CLUSTER
module "eks-cluster" {
  source                        = "../../../../../../modules/aws/eks-cluster"
  eks_cluster_name              = local.eks_cluster_name
  eks_cluster_version           = "1.21"
  eks_cluster_role_arn          = module.eks_cluster_iam_role.role_arn
  eks_cluster_additional_sg_ids = [module.eks_cluster_additional_sg.sg_id]
  eks_cluster_subnets_ids = concat(
    data.terraform_remote_state.network.outputs.public_subnet_ids,
    data.terraform_remote_state.network.outputs.private_subnet_ids
  )
  eks_cluster_control_plane_log_retention = 30 //days

  ## Secret encryption
  secret_encryption_config = [
    {
      provider_key_arn = module.eks_kms_cmk.kms_key_arn
      resources        = ["secrets"]
    }
  ]

  ## Access to cluster
  ## Public & Private
  ## The cluster endpoint is accessible from outside of your VPC. Worker node traffic to the endpoint will stay within your VPC.
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["0.0.0.0/0"]

}
