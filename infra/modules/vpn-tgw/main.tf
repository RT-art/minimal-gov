###############################################
# Minimal Gov: vpn-tgw module
#
# このモジュールは以下のリソースを作成します:
# - Customer Gateway (オンプレミス側の VPN デバイス情報)
# - Transit Gateway への Site-to-Site VPN 接続
# - 静的ルート (必要な宛先 CIDR のみ)
#
# すべてのリソースはセキュアな既定値で作成され、IKEv2 のみを許可します。
###############################################

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Application = var.app_name
      Environment = var.env
      ManagedBy   = "Terraform"
      Region      = var.region
    }
  }
}

###############################################
# Locals
# - name_prefix: リソース名/タグに利用するプレフィックス。
#                未指定の場合は "vpn" を使用します。
###############################################
locals {
  name_prefix = var.name_prefix != null && var.name_prefix != "" ? var.name_prefix : "vpn"
}

###############################################
# Customer Gateway
# - オンプレミス側の VPN デバイス（パブリック IP）を AWS に登録します。
# - BGP ASN は静的ルーティングでも必須値のため入力を求めます。
###############################################
resource "aws_customer_gateway" "this" {
  bgp_asn    = var.customer_gateway_bgp_asn
  ip_address = var.customer_gateway_ip
  type       = "ipsec.1"

  tags = merge(
    {
      Name = "${local.name_prefix}-cgw"
    },
    var.tags,
  )
}

###############################################
# VPN Connection (to Transit Gateway)
# - 静的ルートのみを許可し、BGP を利用しません。
# - IKEv2 を強制し、暗号化アルゴリズムは AWS 既定値を使用します。
###############################################
resource "aws_vpn_connection" "this" {
  customer_gateway_id = aws_customer_gateway.this.id
  transit_gateway_id  = var.transit_gateway_id
  type                = "ipsec.1"

  static_routes_only = true

  # IKEv2 のみを許可（セキュアな既定値）
  tunnel1_ike_versions = ["ikev2"]
  tunnel2_ike_versions = ["ikev2"]

  tags = merge(
    {
      Name = "${local.name_prefix}-vpn"
    },
    var.tags,
  )
}

###############################################
# VPN Connection Routes
# - 接続先 CIDR ごとに静的ルートを作成します。
###############################################
resource "aws_vpn_connection_route" "this" {
  for_each = { for cidr in var.vpn_static_routes : cidr => cidr }

  vpn_connection_id      = aws_vpn_connection.this.id
  destination_cidr_block = each.value
}

