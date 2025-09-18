include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/backend"
}

inputs = {
  versioning_enabled = true
  force_destroy      = true
  lifecycle_days     = 30
}
