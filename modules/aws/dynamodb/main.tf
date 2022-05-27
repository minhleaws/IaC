resource "aws_dynamodb_table" "main" {
  name         = var.table_name
  billing_mode = var.billing_mode

  hash_key  = var.partition_key
  range_key = var.sort_key

  attribute {
    name = var.partition_key
    type = var.partition_key_attr
  }

  attribute {
    name = var.sort_key
    type = var.sort_key_attr
  }

  server_side_encryption {
    # Whether or not to enable encryption at rest using an AWS managed KMS customer master key (CMK).
    enabled     = var.server_side_encryption_enable
    kms_key_arn = var.server_side_encryption_enable == true ? var.kms_key_arn : null
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }

  tags = merge(
    {
      Name = var.table_name
    },
    var.dynamodb_tags,
    var.common_tags
  )
}
