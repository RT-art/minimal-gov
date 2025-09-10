###############################################
# Example: ci-oidc-deploy (minimal)
#
# GitHub Actions からのデプロイを想定した最小構成の例です。
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
module "ci_oidc_deploy" {
  source = "../../modules/ci-oidc-deploy"

  role_name   = "gh-deploy"
  github_org  = "example-org"
  github_repo = "example-repo"
}

###############################################
# Outputs
###############################################
output "role_arn" {
  description = "CI/CD ロールの ARN"
  value       = module.ci_oidc_deploy.role_arn
}

