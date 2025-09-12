###############################################
# Customer Gateway
###############################################
resource "aws_customer_gateway" "this" {
  bgp_asn    = var.bgp_asn
  ip_address = var.customer_gateway_ip
  type       = "ipsec.1"

  tags = merge(
    { Name = "${var.env}-${var.app_name}-cgw" },
    var.tags,
  )
}

###############################################
# VPN Connection (TGW に接続)
###############################################
resource "aws_vpn_connection" "this" {
  transit_gateway_id  = var.transit_gateway_id
  customer_gateway_id = aws_customer_gateway.this.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = merge(
    { Name = "${var.env}-${var.app_name}-vpn" },
    var.tags,
  )
}
