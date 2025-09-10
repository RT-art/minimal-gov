###############################################
# Example: waf-acl (minimal)
#
# この例は、本モジュールを最小限の入力で実行できる構成です。
# - "dev" という名前の Web ACL を作成
# - 172.16.0.0/16 のみを許可する IP Set を作成
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

variable "region" {
  type        = string
  description = "デプロイ先リージョン"
  default     = "ap-northeast-1"
}

variable "app_name" {
  type        = string
  description = "アプリケーション名（default_tags 用）"
  default     = "minimal-gov"
}

variable "env" {
  type        = string
  description = "環境名（default_tags 用）"
  default     = "dev"
}

module "waf_acl" {
  source = "../../modules/waf-acl"

  name        = "dev"
  allow_cidrs = ["172.16.0.0/16"]
}

output "web_acl_arn" {
  value       = module.waf_acl.web_acl_arn
  description = "作成された WAF Web ACL の ARN"
}

output "ip_set_arn" {
  value       = module.waf_acl.ip_set_arn
  description = "許可 CIDR を登録した IP Set の ARN"
}

