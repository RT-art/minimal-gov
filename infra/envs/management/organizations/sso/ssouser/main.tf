terraform {
  required_version = ">= 1.9.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ssoadmin_instances" "this" {}

variable "region" {
  description = "Identity Centerを有効化しているリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "user" {
  description = "作成するIdentity Centerユーザー属性"
  type = object({
    user_name    = string           # 一意なユーザー名（例: taro.portfolio）
    given_name   = string           # 名
    family_name  = string           # 姓
    display_name = string           # 表示名
    email        = string           # メールアドレス（招待/通知に使用）
    phone        = optional(string) # 省略可
  })
  default = {
    user_name    = "taro.portfolio"
    given_name   = "Taro"
    family_name  = "Yamada"
    display_name = "Taro Yamada"
    email        = "taro@example.com"
    # phone      = "+81-90-1234-5678"
  }
}

resource "aws_identitystore_user" "this" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  user_name         = var.user.user_name
  display_name      = var.user.display_name

  name {
    given_name  = var.user.given_name
    family_name = var.user.family_name
  }

  emails {
    value   = var.user.email
    primary = true
  }

  # phoneを指定したときだけ作成
  dynamic "phone_numbers" {
    for_each = try(var.user.phone, null) != null ? [var.user.phone] : []
    content {
      value = phone_numbers.value
      type  = "mobile"
    }
  }
}

output "identity_store_id" {
  value = data.aws_ssoadmin_instances.this.identity_store_ids[0]
}

output "user_id" {
  value = aws_identitystore_user.this.user_id
}
