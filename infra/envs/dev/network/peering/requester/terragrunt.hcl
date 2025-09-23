include "root" {
  path = find_in_parent_folders("env.hcl")
}

dependency "network_vpc" {
  config_path = "../../vpc"
  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

dependency "workload_vpc" {
  config_path = "../../../workload/network/vpc"
  mock_outputs = {
    vpc_id = "vpc-11111111111111111"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

terraform {
  source = "../../../../../modules/network/vpc_peering/requester"
}

inputs = {
  requester_vpc_id = dependency.network_vpc.outputs.vpc_id
  peer_vpc_id      = dependency.workload_vpc.outputs.vpc_id
  peer_owner_id    = "351277498040" # dev account
}

