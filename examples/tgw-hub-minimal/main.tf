###############################################
# Example: tgw-hub (minimal)
#
# この例は、本モジュールを最小限の入力で実行できる構成です。
# TGW と 3 つの TGW ルートテーブルを作成します。
# アタッチメント（VPC/VPN）は作成しません。
###############################################

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
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

module "tgw_hub" {
  source = "../../modules/tgw-hub"

  name                            = "net-tgw"
  description                     = "Minimal Gov TGW Hub"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  # （任意）ルートテーブルの表示名
  rt_name_user             = "tgw-rt-user"
  rt_name_spoke_to_network = "tgw-rt-spoke-to-network"
  rt_name_network_to_spoke = "tgw-rt-network-to-spoke"

  tags = {
    Project = "minimal-gov"
    Env     = "dev"
  }
}

output "tgw_id" {
  value       = module.tgw_hub.tgw_id
  description = "作成された TGW ID"
}

output "tgw_route_tables" {
  description = "作成された TGW ルートテーブル IDs"
  value = {
    user              = module.tgw_hub.rt_user_id
    spoke_to_network  = module.tgw_hub.rt_spoke_to_network_id
    network_to_spoke  = module.tgw_hub.rt_network_to_spoke_id
  }
}

