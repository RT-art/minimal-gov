###############################################
# Example: security-config (minimal)
#
# この例は、本モジュールを最小限の入力で実行できる構成です。
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

################################################
# Variables (for example simplicity)
################################################
variable "region" {
  type        = string
  description = "デプロイ先リージョン"
  default     = "ap-northeast-1"
}

variable "app_name" {
  type        = string
  description = "アプリケーション名"
  default     = "minimal-gov"
}

variable "env" {
  type        = string
  description = "環境名"
  default     = "dev"
}

################################################
# Data sources
################################################
# アカウント ID を取得してバケット名の一意性を担保
data "aws_caller_identity" "current" {}

################################################
# Module usage
################################################
module "security_config" {
  source = "../../modules/security-config"

  env      = var.env
  app_name = var.app_name
  region   = var.region

  # アカウント ID を含めてグローバル一意性を確保
  bucket_name = "config-example-${data.aws_caller_identity.current.account_id}"

  tags = {
    Project = "minimal-gov"
  }
}

output "aggregator_arn" {
  value       = module.security_config.aggregator_arn
  description = "作成された Config Aggregator の ARN"
}

