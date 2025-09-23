variable "route_table_id" { type = string }
variable "destination_cidr" { type = string }
variable "vpc_peering_connection_id" { type = string }

resource "aws_route" "this" {
  route_table_id            = var.route_table_id
  destination_cidr_block    = var.destination_cidr
  vpc_peering_connection_id = var.vpc_peering_connection_id
}
