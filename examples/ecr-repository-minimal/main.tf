###############################################
# Example: ecr-repository (minimal)
#
# この例では、本モジュールを用いて最小限の ECR リポジトリを作成します。
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
  description = "デプロイ先リージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "app_name" {
  description = "アプリケーション名（タグ用）"
  type        = string
  default     = "minimal-gov"
}

variable "env" {
  description = "環境名（タグ用）"
  type        = string
  default     = "dev"
}

###############################################
# ECR Repository Module
###############################################
module "ecr" {
  source = "../../modules/ecr-repository"

  env      = var.env
  app_name = var.app_name
  region   = var.region
  name     = "sample-app"
}

output "repository_url" {
  value       = module.ecr.repository_url
  description = "作成されたリポジトリの URL。docker push/pull 時に利用します。"
}

