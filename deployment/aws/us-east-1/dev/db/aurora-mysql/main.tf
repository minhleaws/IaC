terraform {
  backend "s3" {
    bucket = "minhleaws-terraform-backend-185078133150"
    # The key definition changes following the environment
    key    = "deployment/aws/us-east-1/dev/db/aurora-mysql.tfstate"
    region = "us-east-1"
  }
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.5"
    }
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "minhleaws-terraform-backend-185078133150"
    # The key definition changes following the environment
    key    = "deployment/aws/us-east-1/dev/network.tfstate"
    region = "us-east-1"
  }
}

locals {
  name_prefix = "minhleaws-dev"
  common_tags = {
    env    = "dev"
    tenant = "minhleaws"
  }
  region    = "us-east-1"
  sns_topic = "${local.name_prefix}-rds-events"
}


provider "aws" {
  region = local.region
}

module "rds_aurora_mysql_sg" {
  source = "../../../../../../modules/aws/security-group"

  vpc_id              = data.terraform_remote_state.network.outputs.vpc_id
  security_group_name = "${local.name_prefix}-rds-aurora-mysql-sg"
  description         = "RDS Aurora MySQL SG"
  common_tags         = local.common_tags
  ingress_rules = [
    {
      id          = 1
      description = "Allow private subnets"
      protocol    = "tcp"
      cidr_blocks = data.terraform_remote_state.network.outputs.private_subnet_cidrs
      from_port   = 3306
      to_port     = 3306
    }
  ]
}

data "aws_caller_identity" "current" {}

module "rds_kms_cmk" {
  source = "../../../../../../modules/aws/kms"
  alias  = "alias/${local.name_prefix}-rds"
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

data "sops_file" "secret" {
  source_file = "../../../../../sops/secrets.dev.enc.yaml"
}

module "rds_aurora_mysql" {
  source = "../../../../../../modules/aws/rds-aurora"

  cluster_name = "${local.name_prefix}-rds-aurora-mysql"

  ##1 create subnet group
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  ##2 create db/cluster parameter group
  family = "aurora-mysql8.0"
  //db_parameters = []
  //cluster_parameters = []

  ##3 create cluster
  apply_immediately = true
  engine            = "aurora-mysql"
  engine_version    = "8.0.mysql_aurora.3.01.0"
  database_name     = replace("${local.name_prefix}-db", "-", "")
  master_username   = "root"
  master_password   = data.sops_file.secret.data["db_master_password"]

  //backup retention period
  backup_retention_period      = 7                     #days
  preferred_backup_window      = "17:01-17:31"         #UTC
  preferred_maintenance_window = "sun:16:00-sun:17:00" #UTC

  //security groups
  vpc_security_group_ids = [module.rds_aurora_mysql_sg.sg_id]

  //encrypt at rest
  storage_encrypted = true
  kms_key_arn       = module.rds_kms_cmk.kms_key_arn


  //cluster multi azs
  availability_zones = ["${local.region}a", "${local.region}c", "${local.region}d"]

  ##4. Create instance
  instances      = 1
  instance_class = "db.t3.medium"

}

module "sns_rds_events" {
  source = "../../../../../../modules/aws/sns"

  name               = local.sns_topic
  subcription_emails = ["minh.le.infra@gmail.com"]

  ## https://aws.amazon.com/premiumsupport/knowledge-center/sns-topics-rds-notifications/
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "PolicyForRDSToSNS",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "rds.amazonaws.com"
          },
          "Action" : "SNS:Publish",
          "Resource" : "arn:aws:sns:${local.region}:${data.aws_caller_identity.current.account_id}:${local.sns_topic}",
          "Condition" : {
            "ArnLike" : {
              "aws:SourceArn" : "arn:aws:rds:${local.region}:${data.aws_caller_identity.current.account_id}:*"
            }
          }
        }
      ]
    }
  )

  common_tags = local.common_tags
}

resource "aws_db_event_subscription" "main" {
  name      = local.sns_topic
  sns_topic = module.sns_rds_events.topic_arn

  source_type = "db-cluster"
  source_ids  = [module.rds_aurora_mysql.cluster_id]

  event_categories = [
    "failover",
    "failure",
    "maintenance",
    "notification",
  ]

  tags = local.common_tags
}
