include "root" {
  path = find_in_parent_folders("env.hcl")
}

locals {
  common_config = read_terragrunt_config(find_in_parent_folders("_common.hcl"))
  region        = local.common_config.locals.inputs.region
}

terraform {
  source = "../../../../modules/security/config-aggregator"
}

# Reuse the centralized log archive bucket for AWS Config data
dependency "log_archive" {
  config_path = "../../log/log-archive-s3"
}

inputs = {
  app_name = "minimal-gov-security"

  config_bucket_name = dependency.log_archive.outputs.bucket_name
  config_bucket_arn  = dependency.log_archive.outputs.bucket_arn
  s3_key_prefix      = "AWSLogs/Config"

  global_resource_collector_region = local.region
}
