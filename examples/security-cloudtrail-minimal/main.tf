###############################################
# Example: security-cloudtrail (minimal)
#
# この例では、組織全体の CloudTrail を最小限の入力で作成します。
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

###############################################
# Variables for example
###############################################
variable "region" {
  type        = string
  description = "デプロイ先リージョン"
  default     = "ap-northeast-1"
}

variable "app_name" {
  type        = string
  description = "Application タグに使用する名称"
  default     = "minimal-gov"
}

variable "env" {
  type        = string
  description = "Environment タグ用の値"
  default     = "dev"
}

###############################################
# Module invocation
###############################################
module "security_cloudtrail" {
  source = "../../modules/security-cloudtrail"

  trail_name = "org-trail"
  # bucket_name を省略した場合、ct-logs-<account>-<region> が自動生成されます
  region = var.region
  tags = {
    Project = "minimal-gov"
    Env     = var.env
  }
}

###############################################
# Outputs
###############################################
output "trail_arn" {
  description = "作成された CloudTrail トレイルの ARN"
  value       = module.security_cloudtrail.trail_arn
}

output "bucket_name" {
  description = "CloudTrail ログを格納する S3 バケット名"
  value       = module.security_cloudtrail.bucket_name
}

