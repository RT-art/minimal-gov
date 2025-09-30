include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/network/tgw_route"
}

dependency "tgw_hub" {
  config_path = "../tgw_hub"

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

dependency "tgw_attachment" {
  config_path = "../tgw_attachment"

  mock_outputs = {
    tgw_attachment_id = "tgw-attach-xxxxxxxxxxxxxx"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

dependency "workload_tgw_attachment" {
  config_path = "../../workloads/network/tgw_attachment"

  mock_outputs = {
    tgw_attachment_id = "tgw-attach-xxxxxxxxxxxxxx"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

inputs = {
  # Metadata
  app_name = "minimal-gov-prod-network-tgw-route"
  # Transit Gateway
  transit_gateway_id = dependency.tgw_hub.outputs.tgw_id

  # VPC Attachment IDs
  # - 同じアカウントの VPC は dependency から取得
  # - 他アカウントの VPC はハードコード
  tgw_attachment_ids = merge(
    {
      network = dependency.tgw_attachment.outputs.tgw_attachment_id
    },
    {
      dev = dependency.workload_tgw_attachment.outputs.tgw_attachment_id
    }
  )

  # Route Tables to create
  route_tables = [
    { name = "all-rtb" }
  ]

  # Associations: アタッチメントが入ってくるときに使うテーブル
  route_table_associations = [
    { vpc = "dev", route_table = "all-rtb" },
    { vpc = "network", route_table = "all-rtb" }
  ]

  # Propagations: アタッチメントのルートをどのテーブルに書き込むか
  route_table_propagations = [
    { vpc = "dev", route_table = "all-rtb" },
    { vpc = "network", route_table = "all-rtb" }
  ]
}
