include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../modules/logging/log_archive"
}

inputs = {
  app_name = "minimal-gov-log"
}
