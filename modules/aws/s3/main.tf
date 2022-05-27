resource "aws_s3_bucket" "main" {
  bucket        = var.name
  acl           = var.acl
  policy        = var.policy
  force_destroy = true

  versioning {
    enabled = var.versioning
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.kms_cmk_arn != null ? "aws:kms" : "AES256"
        kms_master_key_id = var.kms_cmk_arn != null ? var.kms_cmk_arn : null
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    iterator = rule

    content {
      id      = rule.value.id
      enabled = lookup(rule.value, "enabled", true)
      prefix  = lookup(rule.value, "prefix", null)

      transition {
        days          = rule.value.transition.days
        storage_class = rule.value.transition.storage_class
      }
    }
  }

  tags = merge(
    { Name = var.name },
    var.tags,
    var.common_tags
  )
}

## Manages S3 bucket-level Public Access Block configuration.
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}
