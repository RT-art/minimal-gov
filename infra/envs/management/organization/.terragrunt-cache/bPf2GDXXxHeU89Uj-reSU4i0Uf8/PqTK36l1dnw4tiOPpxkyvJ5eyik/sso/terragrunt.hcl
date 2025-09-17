include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/organization"
}

inputs = {
org_state_bucket = "aws-remotebackend-bootstrap-tfstate-ap-northeast-1-653502182074" # マスク済み
org_state_key    = "state/organization/terraform.tfstate"
org_state_region = "ap-northeast-1"

user_id = "f774da98-8011-7026-2c88-b28e7383e802"

assigned_accounts = ["dev", "network", "security", "onprem", "ops"]
}
