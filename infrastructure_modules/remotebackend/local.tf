locals {
  s3_bucket_name      = lower("${var.app_name}-tfstate-${var.region}-")
  dynamodb_table_name = lower("${var.app_name}-tf-locks")

  common_tags = merge(var.tags, {
    Environment = var.env
    ManagedBy   = "Terraform"
  })

  versioning = {
    enabled = var.versioning_enabled
  }
  
  global_secondary_indexes = []
  local_secondary_indexes  = []
  replica_regions          = []



}
