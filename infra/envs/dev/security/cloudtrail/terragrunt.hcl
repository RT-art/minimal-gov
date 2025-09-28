include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/security/cloudtrail"
}

# Use the S3 log archive created in the log account
dependency "log_archive" {
  config_path = "../../log/log-archive-s3"
}

inputs = {
  app_name = "minimal-gov-log"

  # Point CloudTrail to the central S3 bucket and prefix
  s3_bucket_name = dependency.log_archive.outputs.bucket_name
  s3_key_prefix  = "AWSLogs"
  kms_key_arn    = dependency.log_archive.outputs.kms_key_arn

  # PoC: create account-level trail under Security acct
  # (Org trail via delegated admin hits provider limitation when reading by ARN)
  is_organization_trail         = false
  include_global_service_events = true
  is_multi_region_trail         = true
}
