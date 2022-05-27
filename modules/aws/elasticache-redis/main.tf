locals {
  subnet_group    = "${var.cluster_name}-subnet-group"
  parameter_group = "${var.cluster_name}-parameter-group"
}

resource "aws_elasticache_subnet_group" "main" {
  name        = local.subnet_group
  description = "Elasticache for Redis subnet group"
  subnet_ids  = var.subnet_ids
}


resource "aws_elasticache_parameter_group" "main" {
  name        = local.parameter_group
  family      = var.family
  description = "Elasticache for Redis parameter group"
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id          = var.cluster_name
  replication_group_description = var.replication_group_description

  parameter_group_name = aws_elasticache_parameter_group.main.name
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = var.security_group_ids

  engine         = "redis"
  engine_version = var.engine_version

  port                  = var.port
  node_type             = var.node_type
  number_cache_clusters = var.node_size

  automatic_failover_enabled = var.automatic_failover_enabled && var.node_size > 1 ? true : false
  availability_zones         = var.availability_zones
  multi_az_enabled           = var.multi_az_enabled

  maintenance_window        = var.maintenance_window
  snapshot_window           = var.snapshot_window
  snapshot_retention_limit  = var.snapshot_retention_limit
  final_snapshot_identifier = "final-snapshot-${var.cluster_name}"

  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = true

  at_rest_encryption_enabled = var.at_rest_encryption_enabled == true ? true : false
  kms_key_id                 = var.kms_key_arn

  tags = merge(
    { Name = var.cluster_name },
    var.common_tags,
  )
}
