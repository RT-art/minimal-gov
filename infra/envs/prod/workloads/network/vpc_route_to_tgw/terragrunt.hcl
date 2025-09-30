include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../../modules/network/vpc_route_to_tgw"
}

dependency "tgw_hub" {
  config_path = "../../../network/tgw_hub"

  mock_outputs = {
    tgw_id = "tgw-aaaaaaaaaaaaaaaaa"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    route_table_id = "rtb-xxx222xxx222xxx22"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

inputs = {
  app_name               = "minimal-gov-prod-workloads-vpc-route-to-tgw"
  route_table_ids        = [dependency.vpc.outputs.route_table_id]
  transit_gateway_id     = dependency.tgw_hub.outputs.tgw_id
  destination_cidr_block = "192.168.0.0/16"
}
