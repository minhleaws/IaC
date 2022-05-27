resource "aws_kms_key" "main" {
  description              = var.description
  key_usage                = var.key_usage
  deletion_window_in_days  = var.deletion_window_in_days
  is_enabled               = var.is_enabled
  enable_key_rotation      = var.enable_key_rotation
  customer_master_key_spec = var.customer_master_key_spec
  policy                   = var.policy
  tags                     = merge(var.common_tags, var.tags)
}

resource "aws_kms_alias" "main" {
  name          = var.alias
  target_key_id = aws_kms_key.main.id
}
