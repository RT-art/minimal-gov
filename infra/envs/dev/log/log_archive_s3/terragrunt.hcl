include "root" {
  path = find_in_parent_folders("env.hcl")
}

# For PoC: use local state here to avoid cross-account
remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    path = "terraform.tfstate"
  }
}

terraform {
  source = "../../../../modules/logging/log_archive"
}

inputs = {
  app_name = "minimal-gov-log"
}
