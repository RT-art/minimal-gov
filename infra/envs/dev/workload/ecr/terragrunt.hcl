include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/compute/ecr"
}

inputs = {
  repository_name         = "minimal-gov/app"
  repository_force_delete = true
}
