###############################################
# Example: ecs-alb-service (minimal)
#
# この例は、本モジュールを最小限の構成で利用する方法を示します。
# - 単純な VPC とプライベートサブネットを 2 つ作成
# - その上に ALB + Fargate サービス (nginx) をデプロイ
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
# 最小限の VPC / Subnet / Route
###############################################
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# 2 つのプライベートサブネット（例では簡易のため CIDR 固定）
resource "aws_subnet" "a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "${var.region}a"
}

resource "aws_subnet" "c" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}c"
}

###############################################
# ecs-alb-service Module
###############################################
module "service" {
  source = "../../modules/ecs-alb-service"

  service_name      = "sample"
  vpc_id            = aws_vpc.this.id
  subnet_ids        = [aws_subnet.a.id, aws_subnet.c.id]
  container_image   = "public.ecr.aws/nginx/nginx:latest"
  container_port    = 80
  desired_count     = 1
  task_cpu          = 256
  task_memory       = 512
  allowed_cidrs     = ["0.0.0.0/0"]
  health_check_path = "/"

  # シンプルな例のためタスクにパブリック IP を付与
  assign_public_ip = true
}

output "alb_dns_name" {
  value       = module.service.alb_dns_name
  description = "作成された ALB の DNS 名"
}

