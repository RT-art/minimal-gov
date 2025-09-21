include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/ecr"
}

inputs = {
  repository_name                   = "minimal-gov/app"
  repository_read_write_access_arns = []
}

