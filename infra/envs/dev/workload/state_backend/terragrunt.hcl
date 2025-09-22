include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/strage/backend"
}

inputs = {
  versioning_enabled = true
  force_destroy      = true
  lifecycle_days     = 30
}
