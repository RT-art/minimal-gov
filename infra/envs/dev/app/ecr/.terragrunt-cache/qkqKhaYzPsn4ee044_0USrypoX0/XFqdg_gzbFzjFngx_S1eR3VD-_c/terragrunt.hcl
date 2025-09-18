include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/ecr"
}

inputs = {
  repository_name = "minimal-gov-ecr"
  repository_read_write_access_arns = [
    "arn:aws:iam::123456789012:role/my-admin-role"
  ]
}
