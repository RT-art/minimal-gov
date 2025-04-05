locals {
  s3_bucket_name      = lower("${var.app_name}-tfstate-${var.region}-${var.aws_account_id}")
  dynamodb_table_name = lower("${var.app_name}-tf-locks")

  common_tags = merge(var.tags, {
    Environment = var.env
    ManagedBy   = "Terraform"
  })

  versioning = {
    enabled = var.versioning_enabled
  }

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]

}
