###############################################
# Example: org-delegations (minimal)
#
# This example demonstrates how to delegate organization-level
# security services to a central security account. Replace the
# placeholder account ID with your actual security account ID before
# applying.
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
# Example inputs
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

# Central security account ID to which we delegate administration.
variable "security_account_id" {
  type        = string
  description = "委任管理者として登録するセキュリティアカウントの ID"
  default     = "111111111111" # TODO: Replace with your actual account ID
}

###############################################
# Module invocation
###############################################
module "org_delegations" {
  source = "../../modules/org-delegations"

  region              = var.region
  app_name            = var.app_name
  env                 = var.env
  security_account_id = var.security_account_id

  # These are true by default; shown here for clarity
  enable_guardduty   = true
  enable_securityhub = true
  enable_cloudtrail  = true
}

