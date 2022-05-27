output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "eks_cluster_id" {
  value = aws_eks_cluster.main.id
}

output "openid_connect_provider_url" {
  value = aws_iam_openid_connect_provider.main.url
}

output "openid_connect_provider_arn" {
  value = aws_iam_openid_connect_provider.main.arn
}
