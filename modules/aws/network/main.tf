locals {
  vpc_name                   = "${var.name_prefix}-vpc"
  public_subnet_prefix_name  = "${var.name_prefix}-public-snet"
  private_subnet_prefix_name = "${var.name_prefix}-private-snet"
}

## CREATE VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    { Name = local.vpc_name },
    var.vpc_tags,
    var.common_tags,
  )
}

## CREATE PUBLIC/PRIVATE SUBNETS
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  availability_zone = element(var.azs, count.index)
  cidr_block        = var.public_subnet_cidrs[count.index]

  #https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#ec2-15-remediation
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = "${local.public_subnet_prefix_name}-${count.index + 1}-${element(var.azs, count.index)}"
    },
    var.public_subnet_tags,
    var.common_tags
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  availability_zone = element(var.azs, count.index)
  cidr_block        = var.private_subnet_cidrs[count.index]

  tags = merge(
    {
      Name = "${local.private_subnet_prefix_name}-${count.index + 1}-${element(var.azs, count.index)}"
    },
    var.private_subnet_tags,
    var.common_tags
  )
}

## CREATE INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    { Name = "${var.name_prefix}-igw" },
    var.igw_tags,
    var.common_tags
  )
}

## CREATE NAT GATEWAY
resource "aws_eip" "ngw" {
  count = var.natgw_multi_az == true ? length(var.azs) : 1
  vpc   = true

  tags = merge(
    {
      Name = "${var.name_prefix}-ngw-eip-${element(var.azs, count.index)}"
    },
    var.natgw_eip_tags,
    var.common_tags
  )
}

resource "aws_nat_gateway" "ngw" {
  count = var.natgw_multi_az == true ? length(var.azs) : 1

  allocation_id = aws_eip.ngw[count.index].id
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(
    {
      Name = "${var.name_prefix}-ngw-${element(var.azs, count.index)}"
    },
    var.natgw_tags,
    var.common_tags
  )
}

## CREATE ROUTE TABLE FOR PUBLIC/PRIVATE SUBNET
## Create Route Table ➜ Route Internet GW ➜ Associate RTB with PUBLIC subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      Name = "${var.name_prefix}-rtb-public-subnet"
    },
    var.rtb_public_subnet_tags,
    var.common_tags
  )
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}

## Create Route Table ➜ Route Nat GW ➜ Associate RTB with PRIVATE subnets
resource "aws_route_table" "private" {
  count = var.natgw_multi_az == true ? length(var.azs) : 1

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[count.index].id
  }

  tags = merge(
    {
      Name = "${var.name_prefix}-rtb-private-subnet-${element(var.azs, count.index)}"
    },
    var.rtb_private_subnet_tags,
    var.common_tags
  )
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

## CREATE NETWORK ACL FOR PUBLIC/PRIVATE SUBNET
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public.*.id

  tags = merge(
    { Name = "${var.name_prefix}-nwacl-public" },
    var.nacl_public_tags,
    var.common_tags,
  )
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private.*.id

  tags = merge(
    { Name = "${var.name_prefix}-nwacl-private" },
    var.nacl_private_tags,
    var.common_tags,
  )
}

## ADD RULE TO NACL
resource "aws_network_acl_rule" "public" {
  for_each = { for rule in var.nacl_public_subnet_rules : rule.id => rule }

  network_acl_id = aws_network_acl.public.id

  egress      = each.value.type == "egress" ? true : false
  protocol    = each.value.protocol
  rule_action = each.value.rule_action
  rule_number = each.value.rule_number
  cidr_block  = each.value.cidr_block
  from_port   = each.value.from_port
  to_port     = each.value.to_port
}

resource "aws_network_acl_rule" "private" {
  for_each = { for rule in var.nacl_private_subnet_rules : rule.id => rule }

  network_acl_id = aws_network_acl.private.id

  egress      = each.value.type == "egress" ? true : false
  protocol    = each.value.protocol
  rule_action = each.value.rule_action
  rule_number = each.value.rule_number
  cidr_block  = each.value.cidr_block
  from_port   = each.value.from_port
  to_port     = each.value.to_port
}
