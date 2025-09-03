# Accounts/Network/vpn.tf
variable "onprem_gateway_ip" {
  description = "オンプレ側ゲートウェイのグローバルIP"
  type        = string
}

variable "onprem_cidr" {
  description = "オンプレ側ネットワークのCIDR"
  type        = string
}

resource "aws_customer_gateway" "onprem" {
  bgp_asn    = 65000
  ip_address = var.onprem_gateway_ip
  type       = "ipsec.1"

  tags = {
    Name = "onprem-cgw"
  }
}

resource "aws_vpn_connection" "onprem" {
  transit_gateway_id  = aws_ec2_transit_gateway.hub.id
  customer_gateway_id = aws_customer_gateway.onprem.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "onprem-vpn"
  }
}

resource "aws_vpn_connection_route" "onprem" {
  vpn_connection_id      = aws_vpn_connection.onprem.id
  destination_cidr_block = var.onprem_cidr
}
