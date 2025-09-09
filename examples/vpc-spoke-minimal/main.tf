###############################################
# Example: vpc-spoke (minimal)
#
# この例は、本モジュールを最小限の入力で実行できる構成です。
# - 2 AZ（最初の 2 つ）を選択
# - 各 AZ に 2 個のプライベートサブネット（合計 4 個）を作成
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

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc_spoke" {
  source = "../../modules/vpc-spoke"

  name_prefix                 = "dev"
  vpc_cidr                    = "10.0.0.0/16"
  azs                         = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnet_count_per_az = 2
  subnet_newbits              = 8

  tags = {
    Project = "minimal-gov"
    Env     = "dev"
  }
}

output "vpc_id" {
  value       = module.vpc_spoke.vpc_id
  description = "作成された VPC ID"
}

output "private_subnet_ids_by_az" {
  value       = module.vpc_spoke.private_subnet_ids_by_az
  description = "AZ ごとのプライベートサブネット IDs"
}

output "route_table_ids" {
  value       = module.vpc_spoke.route_table_ids
  description = "サブネットごとのルートテーブル IDs"
}

