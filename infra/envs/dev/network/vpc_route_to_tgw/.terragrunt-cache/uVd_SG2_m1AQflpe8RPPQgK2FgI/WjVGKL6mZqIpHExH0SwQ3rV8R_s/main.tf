###############################################
# routes to Transit Gateway
###############################################
resource "aws_route" "to_tgw" {
  for_each = toset(var.route_table_ids)

  route_table_id         = each.value
  destination_cidr_block = var.destination_cidr_block
  transit_gateway_id     = var.transit_gateway_id
}
