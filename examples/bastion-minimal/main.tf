###############################################
# Example: bastion (minimal)
#
# この例は、本モジュールを最小限の構成で利用する方法を示します。
# - 単純な VPC + プライベートサブネット + SG を作成
# - そのサブネット上に SSM で接続可能な踏み台 EC2 を 1 台起動
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
# 最小限の VPC / Subnet / SG
###############################################
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = false
}

resource "aws_security_group" "bastion" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.this.id

  # ここではアウトバウンドのみ許可（インバウンドは SSM セッション経由）
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###############################################
# Bastion Module
###############################################
module "bastion" {
  source = "../../modules/bastion"

  subnet_id         = aws_subnet.private.id
  security_group_id = aws_security_group.bastion.id
  instance_type     = "t3.micro"

  tags = {
    Project = "minimal-gov"
    Env     = "dev"
  }
}

output "bastion_instance_id" {
  value       = module.bastion.instance_id
  description = "作成された Bastion EC2 の ID"
}

