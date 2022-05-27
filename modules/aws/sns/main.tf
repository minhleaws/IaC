## Create SNS topic
resource "aws_sns_topic" "main" {
  name = var.name

  # Default Server-side encryption (SSE)
  kms_master_key_id = var.kms_key_arn
  policy            = var.policy
  tags = merge(
    var.sns_tags,
    var.common_tags
  )
}

## Add subcriber email to topic
resource "aws_sns_topic_subscription" "main" {
  for_each = toset(var.subcription_emails)

  topic_arn = aws_sns_topic.main.arn
  protocol  = "email"
  endpoint  = each.value
}
