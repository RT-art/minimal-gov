terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# 1) GitHub OIDC プロバイダ（アカウントに1個）
module "github_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-oidc-provider"
  version = "~> 6.1"

  url  = var.provider_url
  tags = var.tags
}

# 2) Plan 用ロール（GitHub OIDC）
module "plan_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.1"

  name                  = "${var.role_name_prefix}${var.plan_role_name}"
  enable_github_oidc    = true
  oidc_wildcard_subjects = local.plan_subjects
  max_session_duration  = var.max_session_duration

  # AssumeRoleされるポリシー
  # 「AWS全体読み取り」と「tfstateのS3/KMS RW」だけが有効。Planは現実確認するのでReadOnlyは必須。
  policies = merge(
    { for i, arn in var.plan_managed_policy_arns : "managed-${i}" => arn },
    var.state_bucket_arn != null ? { StateBackend = aws_iam_policy.state_backend_readwrite[0].arn } : {}
  )

  tags = var.tags
}

# 3) Apply 用ロール（GitHub OIDC）
module "apply_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.1"

  name                  = "${var.role_name_prefix}${var.apply_role_name}"
  enable_github_oidc    = true
  oidc_wildcard_subjects = local.apply_subjects
  permissions_boundary = var.permissions_boundary_arn
  max_session_duration  = var.max_session_duration

  policies = merge(
    { for i, arn in var.apply_managed_policy_arns : "managed-${i}" => arn },
    var.state_bucket_arn != null ? { StateBackend = aws_iam_policy.state_backend_readwrite[0].arn } : {}
  )

  tags = var.tags
}

# 4) tfstate backend 用（任意）ポリシー: S3 + (任意) KMS
data "aws_iam_policy_document" "state_backend" {
  count = var.state_bucket_arn == null ? 0 : 1

  statement {
    sid     = "S3ListBucket"
    actions = ["s3:ListBucket", "s3:ListBucketVersions"]
    resources = [local.state_bucket_arn_no_slash]
  }

  statement {
    sid       = "S3ObjectRW"
    actions   = [
      "s3:GetObject", "s3:PutObject", "s3:DeleteObject",
      "s3:GetObjectVersion", "s3:DeleteObjectVersion"
    ]
    resources = [local.state_bucket_objects_arn]
  }

  dynamic "statement" {
    for_each = var.kms_key_arn == null ? [] : [1]
    content {
      sid       = "KMSForState"
      actions   = ["kms:Decrypt", "kms:Encrypt", "kms:GenerateDataKey*", "kms:DescribeKey"]
      resources = [var.kms_key_arn]
    }
  }
}

resource "aws_iam_policy" "state_backend_readwrite" {
  count  = var.state_bucket_arn == null ? 0 : 1
  name   = "${var.role_name_prefix}StateBackendRW"
  policy = data.aws_iam_policy_document.state_backend[0].json
  tags   = var.tags
}
