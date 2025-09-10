###############################################
# Example: observability-baseline (minimal)
#
# この例では、既存の ALB / ECS サービス / RDS インスタンスに対して
# 代表的な CloudWatch アラームとダッシュボードを作成します。
# 実際のリソース名に置き換えることでそのまま適用できます。
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

module "observability" {
  source = "../../modules/observability-baseline"

  alb_arn_suffix   = "app/sample/1234567890abcdef" # 実際の ALB arn_suffix に置き換え
  ecs_cluster_name = "sample-cluster"              # 実際のクラスター名に置き換え
  ecs_service_name = "sample-service"              # 実際のサービス名に置き換え
  rds_identifier   = "sample-db"                   # 実際の DB インスタンス識別子に置き換え
  # sns_topic_arn  = "arn:aws:sns:ap-northeast-1:123456789012:notify"  # 任意: 通知先 SNS トピック
}

###############################################
# Outputs
###############################################

output "dashboard_name" {
  description = "作成された CloudWatch ダッシュボードの名前"
  value       = module.observability.dashboard_name
}

output "alarm_arns" {
  description = "作成された CloudWatch アラームの ARN 一覧"
  value       = module.observability.alarm_arns
}

