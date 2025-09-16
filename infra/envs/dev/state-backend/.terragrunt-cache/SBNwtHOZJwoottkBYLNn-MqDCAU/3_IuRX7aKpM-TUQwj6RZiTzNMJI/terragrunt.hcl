include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/backend"
}

inputs = {
    # Metadata
  env      = "dev"
  app_name = "minimal-gov-network"
  region   = "ap-northeast-1"
  tags = {
    Project     = "minimal-gov"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
    # S3 Bucket
  versioning_enabled = true
  force_destroy      = true
  lifecycle_days = 30
}
