## CREATE SG
resource "aws_security_group" "main" {
  name        = var.security_group_name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = var.security_group_name
    },
    var.sg_tags,
    var.common_tags,
  )
}

## CREATE SG INGRESS RULE
resource "aws_security_group_rule" "ingress" {
  for_each          = { for rule in var.ingress_rules : rule.id => rule }
  security_group_id = aws_security_group.main.id

  type                     = "ingress"
  description              = lookup(each.value, "description", null)
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
}

## CREATE SG EGRESS RULE
resource "aws_security_group_rule" "egress" {
  for_each          = { for rule in var.egress_rules : rule.id => rule }
  security_group_id = aws_security_group.main.id

  type                     = "egress"
  description              = lookup(each.value, "description", null)
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
}
