include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/vpc_route_to_tgw"
}

dependency "tgw_hub" {
  config_path = "../tgw_hub"

  mock_outputs = {
    tgw_id = "tgw-aaaaaaaaaaaaaaaaa"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs_merge_with_state           = true
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    route_table_id = "rtb-xxx222xxx222xxx22"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs_merge_with_state           = true
}

inputs = {
  route_table_ids        = [dependency.vpc.outputs.route_table_id]
  transit_gateway_id     = dependency.tgw_hub.outputs.tgw_id
  destination_cidr_block = "10.0.0.0/16"
}
