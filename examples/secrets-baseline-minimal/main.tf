###############################################
# Example: secrets-baseline (minimal)
#
# この例は、2 つの Secrets Manager シークレットを作成する最小構成です。
# 1) db_password: プレーンテキストのパスワード
# 2) app_config : ユーザー名/パスワードを含む JSON オブジェクト
# ローテーションは無効化しています。
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

###############################################
# Module invocation
###############################################
module "secrets_baseline" {
  source = "../../modules/secrets-baseline"

  name_prefix = "demo"
  secrets = {
    db_password = "SuperSecretP@ssw0rd!"
    app_config = {
      username = "demo"
      password = "AnotherSecret!"
    }
  }

  enable_rotation = false
  rotation_days   = 30

  tags = {
    Project = var.app_name
    Env     = var.env
  }
}

###############################################
# Helpful output
###############################################
output "secret_arns" {
  value       = module.secrets_baseline.secret_arns
  description = "作成されたシークレットの ARN マップ"
}

