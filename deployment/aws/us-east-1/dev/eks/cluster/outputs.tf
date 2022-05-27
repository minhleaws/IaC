output "eks_cluster_name" {
  value = module.eks-cluster.eks_cluster_name
}

output "eks_cluster_id" {
  value = module.eks-cluster.eks_cluster_id
}

output "openid_connect_provider_url" {
  value = module.eks-cluster.openid_connect_provider_url
}

output "openid_connect_provider_arn" {
  value = module.eks-cluster.openid_connect_provider_arn
}
