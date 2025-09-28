#############################################
# Log archive S3 bucket (wrapper around terraform-aws-modules/s3-bucket)
#############################################

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_organizations_organization" "this" {}

locals {
  bucket_name = coalesce(
    var.bucket_name,
    lower(replace("${var.app_name}-${var.env}-${data.aws_caller_identity.current.account_id}-log-archive", "[^a-z0-9-]", "-"))
  )

  bucket_arn = "arn:${data.aws_partition.current.partition}:s3:::${local.bucket_name}"

  # Only active accounts in the organization. Handle null safely during PoC.
  organization_account_ids = distinct(
    data.aws_organizations_organization.this.accounts == null ? [] : [
      for account in data.aws_organizations_organization.this.accounts : account.id
      if account.status == "ACTIVE"
    ]
  )

  organization_root_arns = [
    for id in local.organization_account_ids :
    "arn:${data.aws_partition.current.partition}:iam::${id}:root"
  ]

  log_account_root_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"

  kms_admin_principals = distinct(concat([local.log_account_root_arn], var.kms_admin_arns))

  kms_allowed_principals = distinct(concat(local.organization_root_arns, [local.log_account_root_arn]))

  bucket_tags = merge(
    {
      Name        = local.bucket_name
      Environment = var.env
      ManagedBy   = "terraform"
    },
    var.tags,
  )

  log_prefix = trim(var.log_prefix, "/")
}

resource "aws_kms_key" "this" {
  description             = var.kms_description != null ? var.kms_description : "KMS key for ${local.bucket_name}"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms.json
  tags                    = local.bucket_tags
}

resource "aws_kms_alias" "this" {
  name          = var.kms_alias != null ? var.kms_alias : "alias/${local.bucket_name}"
  target_key_id = aws_kms_key.this.key_id
}

module "bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  # NOTE: Terraform requires a static string for module version resolution.
  # Using variables here causes "Variables not allowed" during init.
  version = "~> 4.1"

  bucket = local.bucket_name

  force_destroy = var.force_destroy

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    status = var.versioning_enabled
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.this.arn
      }
      bucket_key_enabled = true
    }
  }

  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket.json

  tags = local.bucket_tags
}

data "aws_iam_policy_document" "kms" {
  statement {
    sid    = "AllowAccountAdministration"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.kms_admin_principals
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudTrailService"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = ["*"]
    # Note: Do not set aws:PrincipalOrgID for service principals; it is not present.
  }

  statement {
    sid    = "AllowOrganizationAccounts"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.kms_allowed_principals
    }

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["s3.${var.region}.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

data "aws_iam_policy_document" "bucket" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      local.bucket_arn,
      "${local.bucket_arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [local.bucket_arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = length(local.organization_account_ids) > 0 ? [
      for account_id in local.organization_account_ids :
      "${local.bucket_arn}/${local.log_prefix}/${account_id}/*"
      ] : [
      "${local.bucket_arn}/${local.log_prefix}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

  }
}
