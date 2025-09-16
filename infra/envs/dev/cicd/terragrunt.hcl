include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/oidc"
}

inputs = {
  github_org  = "RT-art"
  github_repo = "minimal-gov"

}
