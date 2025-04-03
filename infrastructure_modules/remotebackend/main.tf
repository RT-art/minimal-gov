# --- S3 Bucket for Terraform State ---
module "state_bucket" {
  source                               = "../../resource_modules/storage/s3"
  bucket                               = local.s3_bucket_name
  server_side_encryption_configuration = var.server_side_encryption_configuration
  versioning                           = local.versioning
  control_object_ownership             = var.control_object_ownership
  #block_public_acls = true
  #block_public_policy = true
  #ignore_public_acls = true
  #restrict_public_buckets = true
  #object_ownership = "BucketOwnerEnforced"
}

# --- DynamoDB Table for State Locking ---
module "lock_table" {
  source                         = "../../resource_modules/database/dynamodb"
  name                           = local.dynamodb_table_name
  server_side_encryption_enabled = var.server_side_encryption_enabled
  hash_key                       = var.hash_key
  billing_mode                   = var.dynamodb_billing_mode
  deletion_protection_enabled    = var.dynamodb_deletion_protection
  point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
  stream_enabled                 = var.stream_enabled
  ttl_enabled                    = var.ttl_enabled
  create_table                   = var.create_table
  autoscaling_enabled            = var.autoscaling_enabled
  global_secondary_indexes = local.global_secondary_indexes
  local_secondary_indexes  = local.local_secondary_indexes
  replica_regions          = local.replica_regions
  tags                           = local.common_tags
}