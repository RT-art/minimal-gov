include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/compute/ecr"
}

inputs = {
  app_name                           = "minimal-gov-workloads"
  repository_name                   = "minimal-gov/app"
  repository_read_write_access_arns = []
}
