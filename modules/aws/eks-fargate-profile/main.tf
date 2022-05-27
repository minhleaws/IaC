resource "aws_eks_fargate_profile" "main" {
  cluster_name           = var.eks_cluster_name
  fargate_profile_name   = var.fargate_profile_name
  pod_execution_role_arn = var.pod_execution_role_arn
  subnet_ids             = var.subnet_ids

  selector {
    namespace = var.namespace
    labels    = var.labels
  }

  tags = merge(
    {
      Name = var.fargate_profile_name
    },
    var.fargate_profile_tags,
    var.common_tags,
  )
}
