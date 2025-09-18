data "aws_caller_identity" "current" {}

locals {
  s3_bucket_name_raw = lower(replace("${var.app_name}-tfstate-${var.region}-${data.aws_caller_identity.current.account_id}", "_", "-"))
  s3_bucket_name_63  = substr(local.s3_bucket_name_raw, 0, 63)
  s3_bucket_name     = trim(local.s3_bucket_name_63, "-.")
  versioning         = { enabled = var.versioning_enabled }
  account_id         = data.aws_caller_identity.current.account_id
}