module "state_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket                               = local.s3_bucket_name
  versioning                           = { enabled = var.versioning_enabled }
  server_side_encryption_configuration = var.server_side_encryption_configuration

  control_object_ownership = var.control_object_ownership
  object_ownership         = "BucketOwnerEnforced"

  # Public Access Block
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # 通信/暗号化関連のポリシー
  attach_require_latest_tls_policy       = true
  attach_deny_unencrypted_object_uploads = true
  attach_deny_insecure_transport_policy  = true

  expected_bucket_owner = var.aws_account_id
  force_destroy         = false
  tags                  = var.tags

  lifecycle_rule = [{
    id      = "noncurrent-cleanup"
    enabled = true
    noncurrent_version_expiration = {
      days = 180
    }
  }]
}
