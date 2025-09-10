###############################################
# Example: workload-vpce (minimal)
#
# この例では、最小限の VPC とセキュリティグループを用意し、
# workload-vpce モジュールで ECS ワークロードに必要な
# VPC エンドポイント群を作成します。
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
# Inputs for this example
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
# Prepare AZs
###############################################
data "aws_availability_zones" "available" {
  state = "available"
}

###############################################
# Step 1: VPC (from vpc-spoke)
###############################################
module "vpc_spoke" {
  source = "../../modules/vpc-spoke"

  name_prefix                 = "demo"
  vpc_cidr                    = "10.20.0.0/16"
  azs                         = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnet_count_per_az = 1
  subnet_newbits              = 8

  tags = {
    Project = var.app_name
    Env     = var.env
  }
}

###############################################
# Step 2: Security Group for Interface VPCE
# - VPC 内からの 443/TCP のみ許可
###############################################
resource "aws_security_group" "vpce" {
  name        = "demo-vpce-sg"
  description = "Allow HTTPS from VPC"
  vpc_id      = module.vpc_spoke.vpc_id

  ingress {
    description = "Allow HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.20.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###############################################
# Step 3: Workload VPC Endpoints
###############################################
module "workload_vpce" {
  source            = "../../modules/workload-vpce"
  vpc_id            = module.vpc_spoke.vpc_id
  subnet_ids        = flatten([for az, ids in module.vpc_spoke.private_subnet_ids_by_az : ids])
  security_group_id = aws_security_group.vpce.id

  # services を省略するとデフォルトセット(ECR, Secrets, Logs)が作成されます

  tags = {
    Project = var.app_name
    Env     = var.env
  }
}

###############################################
# Helpful outputs
###############################################
output "endpoint_ids" {
  value       = module.workload_vpce.endpoint_ids
  description = "作成された VPCE の ID マップ"
}
