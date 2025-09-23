include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/network/tgw_vpc_attachment_accepter"
}

dependency "workload_tgw_attachment" {
  config_path = "../../workload/network/tgw_attachment"

  mock_outputs = {
    tgw_attachment_id = "tgw-attach-xxxxxxxxxxxxxx"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

inputs = {
  transit_gateway_attachment_id = dependency.workload_tgw_attachment.outputs.tgw_attachment_id
}
