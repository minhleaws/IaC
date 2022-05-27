terraform {
  backend "s3" {
    bucket = "minhleaws-terraform-backend-185078133150"
    # The key definition changes following the environment
    key    = "deployment/aws/us-east-1/dev/db/elasticache-redis.tfstate"
    region = "us-east-1"
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
  region = "us-east-1"
}

provider "aws" {
  region = local.region
}

data "aws_caller_identity" "current" {}

module "elasticache_kms_cmk" {
  source = "../../../../../../modules/aws/kms"
  alias  = "alias/${local.name_prefix}-elasticache"
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

module "elasticache_redis_sg" {
  source = "../../../../../../modules/aws/security-group"

  vpc_id              = data.terraform_remote_state.network.outputs.vpc_id
  security_group_name = "${local.name_prefix}-elasticache-redis-sg"
  description         = "Elasticache for Redis SG"
  common_tags         = local.common_tags
  ingress_rules = [
    {
      id          = 1
      description = "Allow private subnets"
      protocol    = "tcp"
      cidr_blocks = data.terraform_remote_state.network.outputs.private_subnet_cidrs
      from_port   = 6379
      to_port     = 6379
    }
  ]
}

module "elasticache_redis" {
  source = "../../../../../../modules/aws/elasticache-redis"

  cluster_name = "${local.name_prefix}-elasticache-redis"

  ##1 create subnet group
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  ##2. create parameter group
  family = "redis6.x"

  ##3. create replication group
  engine_version             = "6.x"
  node_type                  = "cache.t3.small"
  node_size                  = 1
  availability_zones         = ["${local.region}a"]
  maintenance_window         = "sun:15:00-sun:16:30" #UTC
  snapshot_window            = "17:00-18:00"         #UTC
  snapshot_retention_limit   = 7                     #days
  apply_immediately          = true
  at_rest_encryption_enabled = true
  kms_key_arn                = module.elasticache_kms_cmk.kms_key_arn
  security_group_ids         = [module.elasticache_redis_sg.sg_id]
}
