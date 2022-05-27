output "cluster_id" {
  value = aws_rds_cluster.main.id
}

output "cluster_identifier" {
  value = aws_rds_cluster.main.cluster_identifier
}

output "cluster_endpoint" {
  value = aws_rds_cluster.main.endpoint
}

output "db_name" {
  value = aws_rds_cluster.main.database_name
}
