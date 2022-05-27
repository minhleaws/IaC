output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "private_subnet_cidrs" {
  value = aws_subnet.private.*.cidr_block
}

output "rtb_public_subnet_id" {
  value = aws_route_table.public.id
}

output "rtb_private_subnet_id" {
  value = aws_route_table.private.*.id
}
