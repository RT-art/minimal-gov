include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/security/guardduty"
}

inputs = {
  app_name = "minimal-gov-security"
}
