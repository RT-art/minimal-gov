###############################################
# Example: security-securityhub (minimal)
#
# この例は、単一アカウントで Security Hub を有効化し、
# Organization メンバーを自動有効化、AFSBP 標準に購読し、
# Finding Aggregator で全リージョンのファインディングを集約する最小構成です。
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
# Step: Enable Security Hub
###############################################
module "securityhub" {
  source = "../../modules/security-securityhub"

  auto_enable_members = true
  enable_afsbp        = true
  linking_mode        = "ALL_REGIONS"
}

###############################################
# Helpful outputs (for demo)
###############################################
output "finding_aggregator_arn" {
  value       = module.securityhub.finding_aggregator_arn
  description = "Security Hub Finding Aggregator の ARN"
}

