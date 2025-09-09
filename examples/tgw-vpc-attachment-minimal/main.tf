###############################################
# Example: tgw-vpc-attachment (minimal)
#
# この例は、本モジュールを最小限の入力で実行できる構成です。
# - TGW（modules/tgw-hub）
# - プライベート専用 VPC（modules/vpc-spoke）
# - TGW と VPC のアタッチメント（modules/tgw-vpc-attachment）
#
# 注意：本例は経路の関連付け/伝播は行いません。必要に応じて
# aws_ec2_transit_gateway_route_table_association / propagation を別途作成してください。
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
# Inputs (example local variables)
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
# TGW（ハブ）
###############################################
module "tgw_hub" {
  source = "../../modules/tgw-hub"

  name                            = "net-tgw"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Project = var.app_name
    Env     = var.env
  }
}

###############################################
# VPC（プライベート専用 Spoke）
###############################################
module "vpc_spoke" {
  source = "../../modules/vpc-spoke"

  name_prefix                    = "spoke"
  vpc_cidr                       = "10.10.0.0/16"
  azs                            = [
    "${var.region}a",
    "${var.region}c",
  ]
  private_subnet_count_per_az    = 1
  subnet_newbits                 = 8 # /24 サブネット

  tags = {
    Project = var.app_name
    Env     = var.env
  }
}

###############################################
# アタッチメントで使用するサブネット（2 つを選択）
###############################################
locals {
  flat_private_subnet_ids = flatten(values(module.vpc_spoke.private_subnet_ids_by_az))
  attachment_subnets      = slice(local.flat_private_subnet_ids, 0, 2)
}

###############################################
# TGW ↔ VPC のアタッチメント
###############################################
module "tgw_vpc_attachment" {
  source = "../../modules/tgw-vpc-attachment"

  name                = "spoke-attach"
  transit_gateway_id  = module.tgw_hub.tgw_id
  vpc_id              = module.vpc_spoke.vpc_id
  subnet_ids          = local.attachment_subnets

  # 既定 RT への自動関連付け/伝播は無効（明示制御推奨）
  transit_gateway_default_route_table_association = "disable"
  transit_gateway_default_route_table_propagation = "disable"

  dns_support            = "enable"
  ipv6_support           = "disable"
  appliance_mode_support = "disable"

  tags = {
    Project = var.app_name
    Env     = var.env
  }
}

###############################################
# Outputs (example)
###############################################
output "attachment_id" {
  description = "作成された VPC アタッチメント ID"
  value       = module.tgw_vpc_attachment.attachment_id
}

output "vpc_id" {
  description = "作成された VPC ID"
  value       = module.vpc_spoke.vpc_id
}

output "tgw_id" {
  description = "作成された TGW ID"
  value       = module.tgw_hub.tgw_id
}

