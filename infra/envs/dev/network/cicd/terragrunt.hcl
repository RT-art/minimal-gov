include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/grobal/oidc"
}

inputs = {
  # OIDC
  github_org  = "RT-art"
  github_repo = "minimal-gov"
}
