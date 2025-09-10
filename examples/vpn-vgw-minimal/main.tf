###############################################
# Example: vpn-vgw (minimal)
#
# この例は、vpn-vgw モジュールを用いて VGW + VPN を最小限の
# 入力で構築する方法を示します。
# - デモ用に 1 つのプライベートサブネットのみを持つ VPC を作成
# - オンプレ側 IP はダミー (203.0.113.1) を使用
# - 静的ルートとして 10.1.0.0/16 を登録
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

  # レポジトリ共通のタグ付与（設計書準拠）
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
# Variables (example locals)
###############################################
variable "region" {
  type        = string
  description = "デプロイ先リージョン"
  default     = "ap-northeast-1"
}

variable "app_name" {
  type        = string
  description = "アプリケーション名（タグ用）"
  default     = "minimal-gov"
}

variable "env" {
  type        = string
  description = "環境名（タグ用）"
  default     = "dev"
}

###############################################
# VPC（最小構成）
###############################################
module "vpc_spoke" {
  source = "../../modules/vpc-spoke"

  name_prefix                 = "vpn"
  vpc_cidr                    = "10.100.0.0/16"
  azs                         = ["${var.region}a"]
  private_subnet_count_per_az = 1
  subnet_newbits              = 8

  tags = {
    Project = var.app_name
    Env     = var.env
  }
}

###############################################
# VGW + VPN Connection
###############################################
module "vpn_vgw" {
  source = "../../modules/vpn-vgw"

  vpc_id                   = module.vpc_spoke.vpc_id
  customer_gateway_ip      = "203.0.113.1" # 例: オンプレ側のグローバル IP
  customer_gateway_bgp_asn = 65000
  routes                   = ["10.1.0.0/16"]
  amazon_side_asn          = 64512
  vgw_name                 = "net-vgw"
  cgw_name                 = "onprem-cgw"
  vpn_connection_name      = "net-vpn"

  tags = {
    Project = var.app_name
    Env     = var.env
  }
}

###############################################
# Outputs (example)
###############################################
output "vgw_id" {
  description = "作成された VGW ID"
  value       = module.vpn_vgw.vgw_id
}

output "vpn_connection_id" {
  description = "作成された VPN 接続 ID"
  value       = module.vpn_vgw.vpn_connection_id
}

