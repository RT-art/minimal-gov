###############################################
# Example: rds (minimal)
#
# この例は、本モジュールを最小限の構成で利用する方法を示します。
# - 単純な VPC と 2 つのプライベートサブネットを作成
# - そのサブネット上に MySQL RDS インスタンスを 1 台構築
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
# VPC とプライベートサブネット
###############################################
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = false
}

resource "aws_security_group" "rds" {
  name   = "rds-sg"
  vpc_id = aws_vpc.this.id

  ingress {
    description = "allow MySQL from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###############################################
# RDS Module
###############################################
module "rds" {
  source = "../../modules/rds"

  subnet_ids             = [aws_subnet.private_a.id, aws_subnet.private_c.id]
  vpc_security_group_ids = [aws_security_group.rds.id]
  username               = "admin"
  password               = "P@ssw0rd123"
  db_name                = "demo"
  deletion_protection    = false # 例のため削除保護を無効化
  skip_final_snapshot    = true  # 例のためスナップショットを取得せず削除

  tags = {
    Project = "minimal-gov"
    Env     = "dev"
  }
}

output "db_endpoint" {
  value       = module.rds.db_instance_endpoint
  description = "作成された RDS の接続エンドポイント"
}

