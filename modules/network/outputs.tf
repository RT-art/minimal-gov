output "vpc_id" { value = aws_vpc.this.id }
output "vpc_cidr" { value = var.vpc_cidr }
output "private_subnet_ids" { value = [for s in aws_subnet.private : s.id] }
output "private_subnet_cidrs" { value = [for s in aws_subnet.private : s.cidr_block] }
output "private_route_table_id" { value = aws_route_table.private.id }
output "azs" { value = local.azs }