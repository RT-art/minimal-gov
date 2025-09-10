###############################################
# Example: transfer-family (minimal)
#
# この例は、本モジュールを最小限の設定で利用する方法を示します。
# - 追加の VPC やリソースは不要（PUBLIC エンドポイント）
# - 指定した SSH 公開鍵で接続可能な SFTP サーバとユーザを作成
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

variable "ssh_public_key" {
  description = "SFTP ユーザに紐付ける SSH 公開鍵"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtesmVv08hQ9GzleMFIAk7FFYNO0ilhevia9RNqBm3ELZ1pcU6ZAq/IlBg9qr8zt0sK++VMmgmptvaqYVHkqhNFFexrD68VWW4umk/YnMRzSIvmzzk6Vq8HYPI8RVQG0n3/qEOilXwVA4lb3ksKmEqPwa2DDeqOJCcfoCiM4xNh4GDv5mFLY85U7jti0iUwc3m1/Fc1tN/b5eIV6JqiFMFrFGCxd3bSlkZEYaHB2IIuMkeP5LbVhxWMdKMNs3SkckUa7UB6qruMDoOI9r/s3XFa53mq12drntZvSY4hTIhGpHtIhmZ3r3ENE3j1VFvABmRlMlypF0xLSx9LtyDXcP root@030f361ddfa8"
}

###############################################
# Transfer Family Module
###############################################
module "transfer" {
  source         = "../../modules/transfer-family"
  user_name      = "demo"
  ssh_public_key = var.ssh_public_key

  tags = {
    Project = "minimal-gov"
    Env     = "dev"
  }
}

output "server_endpoint" {
  value       = module.transfer.server_endpoint
  description = "SFTP 接続に利用するエンドポイント"
}

output "bucket_name" {
  value       = module.transfer.bucket_name
  description = "ファイル格納用 S3 バケット名"
}
