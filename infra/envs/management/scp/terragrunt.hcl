include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/scp"
}

locals {
  custom_policies_dir = "${get_terragrunt_dir()}/policies"
}

inputs = {
  custom_policies_dir = local.custom_policies_dir

  add_scps = {
    "SCP-DenyDisableCloudTrail" = {
      description = "CloudTrailの停止・削除を禁止"
      file        = "deny_disable_cloudtrail.json"
      target_id   = "ou-7kvv-z300jxp7"
    }
  }
}
