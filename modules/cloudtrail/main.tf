data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  use_kms    = var.enable_kms_encryption
  create_kms = var.enable_kms_encryption && var.kms_key_arn == null
  bucket_arn = "arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket_name}"
  putobj_arn = var.is_organization_trail ? "${local.bucket_arn}/AWSLogs/*" : "${local.bucket_arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
}

# ------------------------------------------------------------
# S3 bucket for CloudTrail logs 
# ------------------------------------------------------------
resource "aws_s3_bucket" "logs" {
  bucket = var.s3_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # バケット既定は SSE-S3（CloudTrail 本体は KMS で暗号化可能）
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudTrail 書き込み用の最小バケットポリシー
# バケットを覗く許可（GetBucketAcl）
# ログを書き込む許可（PutObject
data "aws_iam_policy_document" "trail_bucket" {
  statement {
    sid     = "AWSCloudTrailAclCheck"
    actions = ["s3:GetBucketAcl"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    resources = [local.bucket_arn]
  }

  statement {
    sid     = "AWSCloudTrailWrite"
    actions = ["s3:PutObject"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    resources = [local.putobj_arn]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.trail_bucket.json
}

# ------------------------------------------------------------
# (Optional) KMS key for CloudTrail SSE-KMS
# ------------------------------------------------------------
resource "aws_kms_key" "trail" {
  count               = local.create_kms ? 1 : 0
  description         = "KMS key for CloudTrail: ${var.trail_name}"
  enable_key_rotation = true
  tags                = var.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableRootPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowCloudTrail"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "kms:EncryptionContext:aws:cloudtrail:arn" = "arn:${data.aws_partition.current.partition}:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "trail" {
  count         = local.create_kms ? 1 : 0
  name          = "alias/cloudtrail-${var.trail_name}"
  target_key_id = aws_kms_key.trail[0].key_id
}

locals {
  kms_key_arn_effective = local.use_kms ? (var.kms_key_arn != null ? var.kms_key_arn : aws_kms_key.trail[0].arn) : null
}

# ------------------------------------------------------------
# CloudTrail
# ------------------------------------------------------------
resource "aws_cloudtrail" "this" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.logs.id
  include_global_service_events = true
  enable_log_file_validation    = true
  is_multi_region_trail         = var.multi_region_trail
  is_organization_trail         = var.is_organization_trail
  enable_logging                = var.enable_logging

  # kmsを作る場合cloudtrailにkmsを渡す
  dynamic "kms_key_id" {
    for_each = local.kms_key_arn_effective == null ? [] : [1]
    content  = local.kms_key_arn_effective
  }

  tags = var.tags
}