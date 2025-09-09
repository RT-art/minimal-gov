###############################################
# Example: vpc-endpoints-baseline (minimal)
#
# この例は、最小限の VPC とサブネットを作成し、その上に
# vpc-endpoints-baseline モジュールで標準的な VPC エンドポイント群を
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
  vpc_cidr                    = "10.10.0.0/16"
  azs                         = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnet_count_per_az = 2
  subnet_newbits              = 8

  tags = {
    Project = var.app_name
    Env     = var.env
  }
}

###############################################
# Step 2: VPC Endpoints Baseline
###############################################
module "vpc_endpoints_baseline" {
  source = "../../modules/vpc-endpoints-baseline"

  name_prefix = "demo"
  vpc_id      = module.vpc_spoke.vpc_id

  # Interface: すべてのプライベートサブネットに配置
  subnet_ids = flatten([
    for az, ids in module.vpc_spoke.private_subnet_ids_by_az : ids
  ])

  # Gateway: 各サブネット専用 RT を関連付け（vpc-spoke の出力をそのまま利用）
  route_table_ids = module.vpc_spoke.route_table_ids

  # SG の許可元は VPC CIDR を明示指定
  allowed_cidrs = ["10.10.0.0/16"]

  # 既定のエンドポイント群を使用（必要に応じて上書き可能）
  enable_interface_endpoints = true
  enable_gateway_endpoints   = true
  enable_private_dns         = true

  tags = {
    Project = var.app_name
    Env     = var.env
  }
}

###############################################
# Helpful outputs (for demo)
###############################################
output "interface_endpoint_ids" {
  value       = module.vpc_endpoints_baseline.interface_endpoint_ids
  description = "作成された Interface VPCE の ID マップ"
}

output "gateway_endpoint_ids" {
  value       = module.vpc_endpoints_baseline.gateway_endpoint_ids
  description = "作成された Gateway VPCE の ID マップ"
}

