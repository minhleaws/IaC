locals {
  db_subnet_group              = "${var.cluster_name}-subnet-group"
  db_parameter_group           = "${var.cluster_name}-parameter-group"
  cluster_parameter_group_name = "${var.cluster_name}-cluster-parameter-group"
}

resource "aws_db_subnet_group" "main" {
  name        = local.db_subnet_group
  description = var.db_subnet_group_description
  subnet_ids  = var.subnet_ids

  tags = merge(
    { Name = local.db_subnet_group },
    var.db_subnet_group_tags,
    var.common_tags,
  )

}

resource "aws_db_parameter_group" "main" {
  name        = local.db_parameter_group
  description = var.db_parameter_group_description
  family      = var.family

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = merge(
    { Name = local.db_parameter_group },
    var.db_parameter_group_tags,
    var.common_tags,
  )
}

resource "aws_rds_cluster_parameter_group" "main" {
  name        = local.cluster_parameter_group_name
  family      = var.family
  description = var.cluster_parameter_group_description

  dynamic "parameter" {
    for_each = var.cluster_parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = merge(
    { Name = local.cluster_parameter_group_name },
    var.cluster_parameter_group_tags,
    var.common_tags,
  )

}


resource "aws_rds_cluster" "main" {
  cluster_identifier = var.cluster_name
  engine             = var.engine
  engine_version     = var.engine_version
  database_name      = var.database_name
  master_username    = var.master_username
  master_password    = var.master_password

  #MultiAZ
  availability_zones = var.availability_zones

  final_snapshot_identifier    = "final-snapshot-${var.cluster_name}"
  copy_tags_to_snapshot        = true
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  vpc_security_group_ids          = var.vpc_security_group_ids
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name
  db_subnet_group_name            = aws_db_subnet_group.main.id
  port                            = var.port
  skip_final_snapshot             = var.skip_final_snapshot
  apply_immediately               = var.apply_immediately
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  kms_key_id        = var.storage_encrypted == true ? var.kms_key_arn : null
  storage_encrypted = var.storage_encrypted

  tags = merge(
    { Name = var.cluster_name },
    var.cluster_tags,
    var.common_tags,
  )
}

resource "aws_rds_cluster_instance" "main" {
  count = var.instances

  availability_zone            = element(var.availability_zones, count.index)
  engine                       = aws_rds_cluster.main.engine
  engine_version               = aws_rds_cluster.main.engine_version
  cluster_identifier           = aws_rds_cluster.main.id
  identifier                   = "${var.cluster_name}-${count.index + 1}"
  instance_class               = var.instance_class
  db_parameter_group_name      = aws_db_parameter_group.main.name
  apply_immediately            = var.apply_immediately
  db_subnet_group_name         = aws_db_subnet_group.main.id
  performance_insights_enabled = var.performance_insights_enabled
  publicly_accessible          = var.publicly_accessible
  preferred_maintenance_window = aws_rds_cluster.main.preferred_maintenance_window
}
