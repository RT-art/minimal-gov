include "root" {
  path = find_in_parent_folders("env.hcl")
}

dependency "vpc" {
  config_path = "../../vpc"
  mock_outputs = {
    route_table_id = "rtb-xxx222xxx222xxx22"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

dependency "peering" {
  config_path = "../requester"
  mock_outputs = {
    peering_connection_id = "pcx-aaaaaaaaaaaaaaaaa"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

terraform {
  source = "../../../../../modules/network/vpc_peering/route"
}

inputs = {
  route_table_id            = dependency.vpc.outputs.route_table_id
  destination_cidr          = "10.0.0.0/16"
  vpc_peering_connection_id = dependency.peering.outputs.peering_connection_id
}

