###############################################
# Example: onprem-sim (minimal)
#
# この例は onprem-sim モジュールを用いて、最小限の疑似オンプレ環境
# (VPC + strongSwan EC2 + EIP) を構築する方法を示します。
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
module "onprem_sim" {
  source = "../../modules/onprem-sim"

  vpc_cidr           = "10.255.0.0/16"
  public_subnet_cidr = "10.255.0.0/24"
  az                 = "${var.region}a"
  instance_type      = "t3.small"
  tags = {
    Project = "minimal-gov"
    Env     = var.env
  }
}

###############################################
# Outputs
###############################################
output "vpc_id" {
  description = "作成された疑似オンプレ VPC の ID"
  value       = module.onprem_sim.vpc_id
}

output "subnet_id" {
  description = "パブリックサブネットの ID"
  value       = module.onprem_sim.subnet_id
}

output "instance_id" {
  description = "strongSwan EC2 インスタンスの ID"
  value       = module.onprem_sim.instance_id
}

output "eip" {
  description = "強制割り当てられた Elastic IP アドレス"
  value       = module.onprem_sim.eip
}

