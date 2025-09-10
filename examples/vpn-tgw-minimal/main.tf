###############################################
# Example: vpn-tgw (minimal)
#
# この例は、本モジュールを最小限の入力で実行できる構成です。
# - 簡易的な Transit Gateway を作成
# - Customer Gateway + VPN 接続を作成し、2 つの静的ルートを追加
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
}

variable "region" {
  type        = string
  description = "デプロイ先リージョン"
  default     = "ap-northeast-1"
}

###############################################
# Transit Gateway (example purposes)
# 実際の環境では既存の TGW ID を渡すことを想定しています。
###############################################
resource "aws_ec2_transit_gateway" "this" {
  description     = "example tgw"
  amazon_side_asn = 64512
}

module "vpn_tgw" {
  source = "../../modules/vpn-tgw"

  env                      = "dev"
  app_name                 = "minimal-gov"
  region                   = var.region
  name_prefix              = "user"
  customer_gateway_ip      = "203.0.113.1"
  customer_gateway_bgp_asn = 65000
  transit_gateway_id       = aws_ec2_transit_gateway.this.id
  vpn_static_routes        = ["10.0.0.0/16", "10.2.0.0/16"]
  tags = {
    Project = "minimal-gov"
    Env     = "dev"
  }
}

output "customer_gateway_id" {
  value       = module.vpn_tgw.customer_gateway_id
  description = "作成された Customer Gateway ID"
}

output "vpn_connection_id" {
  value       = module.vpn_tgw.vpn_connection_id
  description = "作成された VPN 接続 ID"
}

output "tunnel_endpoints" {
  description = "AWS 側トンネル IP アドレス"
  value = {
    tunnel1 = module.vpn_tgw.tunnel1_address
    tunnel2 = module.vpn_tgw.tunnel2_address
  }
}

