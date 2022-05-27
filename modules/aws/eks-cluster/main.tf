## CREATE LOG GROUP TO STORE CONTROL PLANE LOGGING
resource "aws_cloudwatch_log_group" "eks-controll-plane" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/aws/eks/${var.eks_cluster_name}/cluster"
  retention_in_days = var.eks_cluster_control_plane_log_retention
}

resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  version  = var.eks_cluster_version
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids              = var.eks_cluster_subnets_ids
    security_group_ids      = var.eks_cluster_additional_sg_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  ## Secret Encrytion
  dynamic "encryption_config" {
    for_each = toset(var.secret_encryption_config)

    content {
      provider {
        key_arn = encryption_config.value["provider_key_arn"]
      }
      resources = encryption_config.value["resources"]
    }
  }

  ## Amazon EKS control plane logging
  ## https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  depends_on                = [aws_cloudwatch_log_group.eks-controll-plane]
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

## ADD INDENTIY PROVIDER
## https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
## https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-enable-IAM.html
data "tls_certificate" "main" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "main" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.main.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}
