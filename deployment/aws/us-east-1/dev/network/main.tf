terraform {
  backend "s3" {
    bucket = "minhleaws-terraform-backend-185078133150"
    # The key definition changes following the environment
    key    = "deployment/aws/us-east-1/dev/network.tfstate"
    region = "us-east-1"
  }
}

locals {
  vpc_cidr_block       = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.4.0/22", "10.0.8.0/22"]
  public_subnet_cidrs  = ["10.0.12.0/22", "10.0.16.0/22"]
  region               = "us-east-1"
  name_prefix          = "minhleaws-dev"
  common_tags = {
    tenant = "minhleaws"
    env    = "dev"
  }
}

provider "aws" {
  region = local.region
}

module "network" {
  source      = "../../../../../modules/aws/network"
  name_prefix = local.name_prefix

  azs                  = ["${local.region}a", "${local.region}c"]
  vpc_cidr_block       = local.vpc_cidr_block
  private_subnet_cidrs = local.private_subnet_cidrs
  public_subnet_cidrs  = local.public_subnet_cidrs
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  # https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html
  # Recommended network ACL rules for a VPC with public and private subnets (NAT)
  nacl_public_subnet_rules = [
    {
      id          = "ingress-100"
      type        = "ingress"
      protocol    = "tcp"
      rule_number = 100
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 80
      to_port     = 80
    },
    {
      id          = "ingress-110"
      type        = "ingress"
      protocol    = "tcp"
      rule_number = 110
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
    },
    {
      id          = "ingress-120"
      type        = "ingress"
      protocol    = "tcp"
      rule_number = 120
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 22
      to_port     = 22
    },
    {
      id          = "ingress-999"
      type        = "ingress"
      protocol    = "tcp"
      rule_number = 999
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 1024
      to_port     = 65535
    },
    {
      id          = "egress-100"
      type        = "egress"
      protocol    = "tcp"
      rule_number = 100
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 80
      to_port     = 80
    },
    {
      id          = "egress-110"
      type        = "egress"
      protocol    = "tcp"
      rule_number = 110
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
    },
    {
      id          = "egress-120"
      type        = "egress"
      protocol    = "tcp"
      rule_number = 120
      rule_action = "allow"
      cidr_block  = local.vpc_cidr_block
      from_port   = 22
      to_port     = 22
    },
    {
      id          = "egress-999"
      type        = "egress"
      protocol    = "tcp"
      rule_number = 999
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 1024
      to_port     = 65535
    },
  ]

  nacl_private_subnet_rules = [
    {
      id          = "ingress-100"
      type        = "ingress"
      protocol    = "tcp"
      rule_number = 100
      rule_action = "allow"
      cidr_block  = local.vpc_cidr_block
      from_port   = 22
      to_port     = 22
    },
    {
      id          = "ingress-110"
      type        = "ingress"
      protocol    = "tcp"
      rule_number = 110
      rule_action = "allow"
      cidr_block  = local.vpc_cidr_block
      from_port   = 80
      to_port     = 80
    },
    {
      id          = "ingress-120"
      type        = "ingress"
      protocol    = "tcp"
      rule_number = 120
      rule_action = "allow"
      cidr_block  = local.vpc_cidr_block
      from_port   = 443
      to_port     = 443
    },
    {
      id          = "ingress-999"
      type        = "ingress"
      protocol    = "tcp"
      rule_number = 999
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 1024
      to_port     = 65535
    },
    {
      id          = "egress-100"
      type        = "egress"
      protocol    = "tcp"
      rule_number = 100
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 80
      to_port     = 80
    },
    {
      id          = "egress-110"
      type        = "egress"
      protocol    = "tcp"
      rule_number = 110
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
    },
    {
      id          = "egress-999"
      type        = "egress"
      protocol    = "tcp"
      rule_number = 999
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 1024
      to_port     = 65535
    }
  ]

  common_tags = local.common_tags
}
