include "root" {
  path = find_in_parent_folders("env.hcl")
}

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
  source = "../../../../modules/strage/log_archive_s3"
}

inputs = {
  app_name = "minimal-gov-log"
}
