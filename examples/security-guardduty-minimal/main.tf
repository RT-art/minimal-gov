###############################################
# Example: security-guardduty (minimal)
#
# この例は、単一アカウントで GuardDuty を有効化し、
# Organization メンバーに対しても自動的に機能を有効化する最小構成です。
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
# Step: Enable GuardDuty
###############################################
module "guardduty" {
  source = "../../modules/security-guardduty"

  # name_prefix の例として "demo" を付与
  name_prefix         = "demo"
  auto_enable_members = "ALL"

  tags = {
    Project = var.app_name
    Env     = var.env
  }
}

###############################################
# Helpful outputs (for demo)
###############################################
output "detector_id" {
  value       = module.guardduty.detector_id
  description = "作成された GuardDuty Detector の ID"
}

