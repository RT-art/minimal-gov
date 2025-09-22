locals {
  common    = read_terragrunt_config(find_in_parent_folders("_common.hcl"))
  provider  = read_terragrunt_config(find_in_parent_folders("_provider.hcl"))
  versions  = read_terragrunt_config(find_in_parent_folders("_versions.hcl"))
  backend   = read_terragrunt_config(find_in_parent_folders("_remote_state.hcl"))
}

inputs = local.common.locals.inputs