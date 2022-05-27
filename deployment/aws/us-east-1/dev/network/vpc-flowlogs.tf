locals {
  bucket_name = "${local.name_prefix}-vpc-flow-logs"
}

data "aws_caller_identity" "current" {}

module "vpc_flow_logs_s3" {
  source = "../../../../../modules/aws/s3"

  name       = local.bucket_name
  versioning = false
  acl        = "log-delivery-write"

  ## https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-s3.html
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AWSLogDeliveryWrite",
          "Effect" : "Allow",
          "Principal" : { "Service" : "delivery.logs.amazonaws.com" },
          "Action" : "s3:PutObject",
          "Resource" : "arn:aws:s3:::${local.bucket_name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
          "Condition" : {
            "StringEquals" : {
              "s3:x-amz-acl" : "bucket-owner-full-control",
              "aws:SourceAccount" : "${data.aws_caller_identity.current.account_id}"
            },
            "ArnLike" : {
              "aws:SourceArn" : "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:*"
            }
          }
        },
        {
          "Sid" : "AWSLogDeliveryCheck",
          "Effect" : "Allow",
          "Principal" : { "Service" : "delivery.logs.amazonaws.com" },
          "Action" : ["s3:GetBucketAcl", "s3:ListBucket"],
          "Resource" : "arn:aws:s3:::${local.bucket_name}",
          "Condition" : {
            "StringEquals" : {
              "aws:SourceAccount" : "${data.aws_caller_identity.current.account_id}"
            },
            "ArnLike" : {
              "aws:SourceArn" : "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:*"
            }
          }
        }
      ]
    }
  )

  lifecycle_rules = [
    {
      id      = "transition_glacier",
      enabled = true
      transition = {
        days          = 1
        storage_class = "GLACIER"
      }
    }
  ]
}

resource "aws_flow_log" "s3" {
  log_destination      = module.vpc_flow_logs_s3.bucket_arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = module.network.vpc_id
}
