###############################################
# Minimal Gov: VPN via VGW module
#
# このモジュールは以下のリソースを作成します:
# - Virtual Private Gateway (VGW)
# - VGW を指定された VPC にアタッチ
# - Customer Gateway (オンプレ側)
# - VPN Connection (VGW ↔ Customer Gateway)
# - オンプレ宛の静的ルート
#
# これにより Network アカウントとオンプレ/DC 間の Site-to-Site VPN を
# 迅速かつ安全に構築できます。VPN は静的ルートのみを許可し、
# セキュアなデフォルトで構成されています。
###############################################

###############################################
# VGW 本体
# - Amazon 側 ASN は既定 64512（必要に応じて変更可能）
###############################################
resource "aws_vpn_gateway" "this" {
  amazon_side_asn = var.amazon_side_asn

  tags = merge(
    {
      Name = var.vgw_name
    },
    var.tags,
  )
}

###############################################
# VGW ↔ VPC の関連付け
# - 指定された VPC に VGW をアタッチします。
###############################################
resource "aws_vpn_gateway_attachment" "this" {
  vpn_gateway_id = aws_vpn_gateway.this.id
  vpc_id         = var.vpc_id
}

###############################################
# Customer Gateway（オンプレ側）
# - オンプレ拠点のグローバル IP と BGP ASN を登録
###############################################
resource "aws_customer_gateway" "this" {
  bgp_asn    = var.customer_gateway_bgp_asn
  ip_address = var.customer_gateway_ip
  type       = "ipsec.1"

  tags = merge(
    {
      Name = var.cgw_name
    },
    var.tags,
  )
}

###############################################
# VPN Connection（VGW ↔ Customer Gateway）
# - 静的ルートのみを許可しシンプルに構成
###############################################
resource "aws_vpn_connection" "this" {
  vpn_gateway_id      = aws_vpn_gateway.this.id
  customer_gateway_id = aws_customer_gateway.this.id
  type                = "ipsec.1"

  # BGP を使わず静的ルートで運用するため true
  static_routes_only = true

  tags = merge(
    {
      Name = var.vpn_connection_name
    },
    var.tags,
  )
}

###############################################
# VPN 接続の静的ルート
# - オンプレミス側の宛先 CIDR を登録
###############################################
resource "aws_vpn_connection_route" "this" {
  for_each = toset(var.routes)

  vpn_connection_id      = aws_vpn_connection.this.id
  destination_cidr_block = each.key
}

