include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/log/cloudtrail"
}

inputs = {
  app_name       = "minimal-gov-log"
  s3_bucket_name = "minimal-gov-log-cloudtrail-logs"

  # Optional features can be toggled as needed
  is_organization_trail         = true
  include_global_service_events = true
  is_multi_region_trail         = true
}
