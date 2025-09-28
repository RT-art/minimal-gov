include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/security/security-hub"
}

inputs = {
  app_name = "minimal-gov-security"
}
