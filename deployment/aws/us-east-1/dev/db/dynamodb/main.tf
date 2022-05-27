terraform {
  backend "s3" {
    bucket = "minhleaws-terraform-backend-185078133150"
    # The key definition changes following the environment
    key    = "deployment/aws/us-east-1/dev/db/dynamodb.tfstate"
    region = "us-east-1"
  }
}


locals {
  name_prefix = "minhleaws-dev"
  common_tags = {
    env    = "dev"
    tenant = "minhleaws"
  }
  region = "us-east-1"
}

provider "aws" {
  region = local.region
}

data "aws_caller_identity" "current" {}

module "dynamodb_kms_cmk" {
  source = ".../../../../../../modules/aws/kms"

  alias = "alias/${local.name_prefix}-dynamodb"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Id" : "KMSPolicy",
      "Statement" : [
        {
          "Sid" : "Enable IAM User Permissions",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          },
          "Action" : "kms:*",
          "Resource" : "*"
        }
      ]
    }
  )

  common_tags = local.common_tags
}

# aws dynamodb describe-table --table-name minhleaws-v1-dev --profile minhleaws-dev
module "dynamodb_minhleaws_v1_dev" {
  source = "../../../../../../modules/aws/dynamodb"

  table_name = "minhleaws-v1-dev"

  partition_key      = "driver_id"
  partition_key_attr = "N"
  sort_key           = "actioned_at"
  sort_key_attr      = "N"

  # The valid values are PROVISIONED and PAY_PER_REQUEST(on-demand)
  billing_mode = "PAY_PER_REQUEST"

  # Encryption at rest
  # Whether or not to enable encryption at rest using an AWS managed KMS customer master key (CMK).
  # Default the AWS KMS key is owned and managed by DynamoDB
  server_side_encryption_enable = true
  kms_key_arn                   = module.dynamodb_kms_cmk.kms_key_arn

  # Backup
  point_in_time_recovery = true
}
