###############################################
# Transit Gateway VPC Attachment
###############################################
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids

  dns_support                       = var.dns_support  ? "enable" : "disable"
  ipv6_support                      = var.ipv6_support ? "enable" : "disable"
  appliance_mode_support            = var.appliance_mode_support ? "enable" : "disable"
  transit_gateway_default_route_table_association = var.default_route_table_association ? "enable" : "disable"
  transit_gateway_default_route_table_propagation = var.default_route_table_propagation ? "enable" : "disable"

  tags = merge(
    var.tags,
    { Name = "tgw-att-${var.vpc_name}" }
  )
}
