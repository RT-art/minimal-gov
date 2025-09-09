###############################################
# Example: resolver-endpoints (minimal)
#
# この例は、最小限の VPC とサブネットを作成し、その上に
# resolver-endpoints モジュールで Inbound/Outbound Resolver Endpoints を
# 作成する構成です。
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

###############################################
# Provider (repo-wide standard)
###############################################
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
# Inputs for this example
###############################################
variable "region" {
  type        = string
  description = "デプロイ先リージョン"
  default     = "ap-northeast-1"
}

variable "app_name" {
  type        = string
  description = "アプリケーション名。タグに使用します。"
  default     = "minimal-gov"
}

variable "env" {
  type        = string
  description = "環境名（例: dev, stg, prd）。タグに使用します。"
  default     = "dev"
}

###############################################
# Prepare AZs
###############################################
data "aws_availability_zones" "available" {
  state = "available"
}

###############################################
# Step 1: VPC (from vpc-spoke)
###############################################
module "vpc_spoke" {
  source = "../../modules/vpc-spoke"

  name_prefix                 = "demo"
  vpc_cidr                    = "10.20.0.0/16"
  azs                         = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnet_count_per_az = 2
  subnet_newbits              = 8

  tags = {
    Project = var.app_name
    Env     = var.env
  }
}

###############################################
# Step 2: Resolver Endpoints
# - Inbound: 最初の 2 サブネットを利用
# - Outbound: 次の 2 サブネットを利用（例示として有効化）
###############################################
locals {
  all_private_subnets = flatten([
    for az, ids in module.vpc_spoke.private_subnet_ids_by_az : ids
  ])
}

module "resolver_endpoints" {
  source = "../../modules/resolver-endpoints"

  name_prefix = "demo"
  vpc_id      = module.vpc_spoke.vpc_id

  # Inbound: VPC 内からの到達を想定して VPC CIDR を許可
  create_inbound        = true
  inbound_subnet_ids    = slice(local.all_private_subnets, 0, 2)
  inbound_allowed_cidrs = ["10.20.0.0/16"]

  # Outbound: 例として有効化（フォワード先ルールは別途作成してください）
  create_outbound       = true
  outbound_subnet_ids   = slice(local.all_private_subnets, 2, 4)

  tags = {
    Project = var.app_name
    Env     = var.env
  }
}

###############################################
# Helpful outputs (for demo)
###############################################
output "resolver_security_group_id" {
  value       = module.resolver_endpoints.security_group_id
  description = "Resolver 用 SG の ID"
}

output "inbound_endpoint_id" {
  value       = module.resolver_endpoints.inbound_endpoint_id
  description = "作成された Inbound Resolver Endpoint の ID"
}

output "outbound_endpoint_id" {
  value       = module.resolver_endpoints.outbound_endpoint_id
  description = "作成された Outbound Resolver Endpoint の ID"
}

