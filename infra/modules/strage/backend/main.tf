# S3バケット本体
resource "aws_s3_bucket" "this" {
  bucket        = local.s3_bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket" "access_logs" {
  count         = var.enable_access_logs ? 1 : 0
  bucket        = local.access_logs_bucket_name
  force_destroy = true
  acl           = "log-delivery-write"
  tags = merge(
    var.tags,
    {
      Purpose = "s3-access-logs"
    }
  )
}

# 所有権:BucketOwnerEnforced（ACL 無効化）
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Public Access Blockを全て有効
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  count                   = var.enable_access_logs ? 1 : 0
  bucket                  = aws_s3_bucket.access_logs[count.index].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# バージョニング
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# サーバー側暗号化（AES256既定。use_kms=trueならKMS）
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.use_kms ? "aws:kms" : "AES256"
      kms_master_key_id = var.use_kms ? var.kms_master_key_id : null
    }
    # KMS利用時はBucket Keyでコスト最適化
    bucket_key_enabled = var.use_kms
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  count  = var.enable_access_logs ? 1 : 0
  bucket = aws_s3_bucket.access_logs[count.index].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
      kms_master_key_id = null
    }
  }
}

# 旧バージョンのライフサイクル削除
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "noncurrent-cleanup"
    status = "Enabled"
    # すべてのオブジェクトに適用
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_days
    }
  }

  rule {
    id     = "abort-incomplete-mpu"
    status = "Enabled"
    filter {}
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }


  # versioning 設定が先に入っていると安全
  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  count  = var.enable_access_logs ? 1 : 0
  bucket = aws_s3_bucket.access_logs[count.index].id

  rule {
    id     = "expire-access-logs"
    status = "Enabled"
    filter {}

    expiration {
      days = 365
    }
  }
}

# バケットポリシー（TLS1.2+ 強制 / HTTP 拒否 / 平文アップロード拒否）
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  # PutObject 時に SSE ヘッダ必須
  statement {
    sid     = "DenyUnEncryptedObjectUploads"
    effect  = "Deny"
    actions = ["s3:PutObject"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = ["${aws_s3_bucket.this.arn}/*"]

    # ヘッダが無いアップロードを拒否
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
    # 変な値の SSE も拒否（KMS 指定時は KMS のみ許可）
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = var.use_kms ? ["aws:kms"] : ["AES256", "aws:kms"]
    }
  }

  # 最低 TLS1.2 を要求
  statement {
    sid     = "RequireLatestTLS"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]
    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = ["1.2"]
    }
  }
}

locals {
  allowed_principals = [for id in var.allowed_account_ids : "arn:aws:iam::${id}:root"]
}

# Cross-account allow (only when allowed_account_ids is non-empty)
data "aws_iam_policy_document" "allow_cross_account" {
  count = length(var.allowed_account_ids) > 0 ? 1 : 0

  # Bucket-level permissions: List and GetBucketLocation
  statement {
    sid    = "AllowCrossAccountBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    principals {
      type        = "AWS"
      identifiers = local.allowed_principals
    }
    resources = [aws_s3_bucket.this.arn]
  }

  # Object-level permissions: read/write state objects
  statement {
    sid    = "AllowCrossAccountObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    principals {
      type        = "AWS"
      identifiers = local.allowed_principals
    }
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
}

# Merge deny baseline and optional cross-account allows
data "aws_iam_policy_document" "policy_combined" {
  source_policy_documents   = [data.aws_iam_policy_document.bucket_policy.json]
  override_policy_documents = length(data.aws_iam_policy_document.allow_cross_account) > 0 ? [data.aws_iam_policy_document.allow_cross_account[0].json] : []
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.policy_combined.json

  # 所有権/公開ブロックが整ってからポリシー投入
  depends_on = [
    aws_s3_bucket_ownership_controls.this,
    aws_s3_bucket_public_access_block.this,
  ]
}

resource "aws_s3_bucket_logging" "this" {
  count         = var.enable_access_logs ? 1 : 0
  bucket        = aws_s3_bucket.this.id
  target_bucket = aws_s3_bucket.access_logs[count.index].id
  target_prefix = var.access_logs_prefix
}
