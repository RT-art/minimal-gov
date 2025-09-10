###############################################
# Example: sso-permission-set (minimal)
#
# この例では IAM Identity Center に AdministratorAccess 権限の
# Permission Set を作成します。アカウントへの割当は行っていません。
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
module "sso_permission_set" {
  source = "../../modules/sso-permission-set"

  permission_set_name = "AdministratorAccess"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]

  tags = {
    Project = "minimal-gov"
    Env     = var.env
  }
}

###############################################
# Outputs
###############################################
output "permission_set_arn" {
  description = "作成された Permission Set の ARN"
  value       = module.sso_permission_set.permission_set_arn
}

