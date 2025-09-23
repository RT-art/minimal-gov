include "root" {
  path = find_in_parent_folders("env.hcl")
}

dependency "peering_request" {
  config_path = "../../../network/peering/requester"
  mock_outputs = {
    peering_connection_id = "pcx-aaaaaaaaaaaaaaaaa"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

terraform {
  source = "../../../../../modules/network/vpc_peering/accepter"
}

inputs = {
  peering_connection_id = dependency.peering_request.outputs.peering_connection_id
}

