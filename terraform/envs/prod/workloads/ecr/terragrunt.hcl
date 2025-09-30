include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/compute/ecr"
}

inputs = {
  app_name                = "minimal-gov-ecr"
  repository_name         = "minimal-gov"
  repository_force_delete = true
}

