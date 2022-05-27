resource "aws_vpc_endpoint" "s3" {
  vpc_id          = module.network.vpc_id
  route_table_ids = concat([module.network.rtb_public_subnet_id], module.network.rtb_private_subnet_id)
  service_name    = "com.amazonaws.${local.region}.s3"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-s3-vpc-gwep"
    }
  )
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id          = module.network.vpc_id
  route_table_ids = concat([module.network.rtb_public_subnet_id], module.network.rtb_private_subnet_id)
  service_name    = "com.amazonaws.${local.region}.dynamodb"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-dynamodb-vpc-gwep"
    }
  )
}

module "sqs_vpcep_sg" {
  source = "../../../../../modules/aws/security-group"

  vpc_id              = module.network.vpc_id
  security_group_name = "${local.name_prefix}-sqs-vpc-ifep-sg"
  description         = "SQS VPC Endpoint SG"
  common_tags         = local.common_tags
  ingress_rules = [
    {
      id          = 1
      description = "Allow private cidr"
      protocol    = "tcp"
      cidr_blocks = local.private_subnet_cidrs
      from_port   = 0
      to_port     = 65535
    }
  ]

  egress_rules = [
    {
      id          = 1
      description = "Allow private cidr"
      protocol    = "tcp"
      cidr_blocks = local.private_subnet_cidrs
      from_port   = 0
      to_port     = 65535
    }
  ]
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = module.network.vpc_id
  subnet_ids          = module.network.private_subnet_ids
  security_group_ids  = [module.sqs_vpcep_sg.sg_id]
  service_name        = "com.amazonaws.${local.region}.sqs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-sqs-vpc-ifep"
    }
  )
}
