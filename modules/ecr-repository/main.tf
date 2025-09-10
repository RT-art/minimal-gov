###############################################
# Minimal Gov: ECR Repository module
#
# このモジュールは、アプリケーションのコンテナイメージを保存する
# セキュアな Amazon ECR プライベートリポジトリを作成します。
# 主な機能:
# - プッシュ時のイメージスキャンを既定で有効化 (脆弱性検出)
# - KMS による暗号化を強制（未指定時は AWS 管理キー）
# - タグのイミュータビリティを強制 (意図しない上書きを防止)
# - ライフサイクルポリシーで最新イメージのみ保持
# - 任意で他アカウントからの pull を許可
#
# これにより、最小限の入力でガバナンスに沿った ECR リポジトリを
# 即座に利用できます。
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
# ECR Repository
# - セキュアな既定値をフルで有効化
###############################################
resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = "IMMUTABLE" # タグ上書きを防止

  # プッシュ時にイメージスキャンを実施
  image_scanning_configuration {
    scan_on_push = true
  }

  # KMS で暗号化 (キー未指定なら AWS 管理キー)
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  tags = merge(
    { Name = var.name },
    var.tags,
  )
}

###############################################
# Lifecycle Policy
# - 過去のイメージを自動削除し、最新のみ保持
###############################################
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Retain last ${var.keep_last_images} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.keep_last_images
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

###############################################
# Cross-account Pull Policy (optional)
# - pull_principal_arns に渡された IAM Principal に pull を許可
###############################################
data "aws_iam_policy_document" "cross_account" {
  count = length(var.pull_principal_arns) > 0 ? 1 : 0

  statement {
    sid = "AllowCrossAccountPull"
    principals {
      type        = "AWS"
      identifiers = var.pull_principal_arns
    }

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
    ]
  }
}

resource "aws_ecr_repository_policy" "cross_account" {
  count      = length(var.pull_principal_arns) > 0 ? 1 : 0
  repository = aws_ecr_repository.this.name
  policy     = data.aws_iam_policy_document.cross_account[0].json
}

