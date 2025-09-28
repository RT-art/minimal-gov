include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/security/inspector"
}

inputs = {
  app_name = "minimal-gov-security"
}
