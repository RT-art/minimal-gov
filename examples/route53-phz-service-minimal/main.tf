###############################################
# Example: route53-phz-service (minimal)
#
# この例では、最小限の VPC と Network Load Balancer を作成し、
# その DNS 名を Route53 プライベートホストゾーンに ALIAS レコードとして登録します。
#
# `terraform apply` により、以下が作成されます:
# - VPC (vpc-spoke モジュール)
# - 内部向け Network Load Balancer
# - PHZ と ALIAS レコード
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
# Step 1: VPC (from vpc-spoke module)
###############################################
module "vpc_spoke" {
  source = "../../modules/vpc-spoke"

  name_prefix                 = "demo"
  vpc_cidr                    = "10.30.0.0/16"
  azs                         = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnet_count_per_az = 2
  subnet_newbits              = 8

  tags = {
    Project = var.app_name
    Env     = var.env
  }
}

###############################################
# Step 2: Dummy Network Load Balancer
# - 実際のターゲットは登録しませんが、DNS 名と zone_id を得る目的で作成します。
###############################################
locals {
  all_private_subnets = flatten([
    for az, ids in module.vpc_spoke.private_subnet_ids_by_az : ids
  ])
}

resource "aws_lb" "demo" {
  name                       = "demo-nlb"
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = slice(local.all_private_subnets, 0, 2)
  enable_deletion_protection = false

  tags = {
    Name    = "demo-nlb"
    Project = var.app_name
    Env     = var.env
  }
}

###############################################
# Step 3: Route53 PHZ Service module
###############################################
module "phz_service" {
  source = "../../modules/route53-phz-service"

  zone_name = "svc.local"
  vpc_id    = module.vpc_spoke.vpc_id
  records = [{
    name          = "api"
    type          = "A"
    alias_zone_id = aws_lb.demo.zone_id
    alias_name    = aws_lb.demo.dns_name
  }]

  tags = {
    Project = var.app_name
    Env     = var.env
  }
}

###############################################
# Helpful outputs (for demo)
###############################################
output "phz_zone_id" {
  value       = module.phz_service.zone_id
  description = "作成された PHZ の ID"
}
