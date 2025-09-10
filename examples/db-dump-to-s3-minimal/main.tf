###############################################
# Example: db-dump-to-s3 (minimal)
#
# この例では、最小限のリソースで DB ダンプをスケジュール実行し
# S3 へ保存するモジュールの使い方を示します。
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
# Example variables
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
# Prerequisite resources
###############################################
# デフォルト VPC とそのサブネットを利用します。
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# タスク用のセキュリティグループ (全通信許可)
resource "aws_security_group" "db_dump" {
  name   = "db-dump-sg"
  vpc_id = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ダンプ保存先 S3 バケット (実際の運用ではユニークな名前に変更してください)
resource "aws_s3_bucket" "dump" {
  bucket        = "${var.app_name}-${var.env}-db-dump"
  force_destroy = true
}

# RDS 接続情報のダミー Secret
resource "aws_secretsmanager_secret" "db" {
  name = "${var.app_name}-${var.env}-db-secret"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = "user"
    password = "pass"
    host     = "db.example.com"
    port     = 5432
    dbname   = "app"
  })
}

###############################################
# Module invocation
###############################################
module "db_dump" {
  source = "../../modules/db-dump-to-s3"

  subnet_ids          = data.aws_subnets.default.ids
  security_group_id   = aws_security_group.db_dump.id
  vpc_id              = data.aws_vpc.default.id
  rds_secret_arn      = aws_secretsmanager_secret.db.arn
  engine              = "postgresql"
  s3_bucket           = aws_s3_bucket.dump.bucket
  s3_prefix           = "daily"
  schedule_expression = "rate(1 day)"
  task_cpu            = 256
  task_memory         = 512
}

###############################################
# Outputs
###############################################
output "rule_arn" {
  value       = module.db_dump.rule_arn
  description = "EventBridge ルールの ARN"
}

output "task_definition_arn" {
  value       = module.db_dump.task_definition_arn
  description = "ECS タスク定義の ARN"
}

