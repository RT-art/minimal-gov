include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/routes_to_tgw"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  # Dev VPCのプライベートRTBに、Network VPC(192.168.0.0/16)宛のルートをTGWへ追加
  route_table_ids        = [dependency.vpc.outputs.route_table_id]
  # TGWはNetworkアカウントにあるため、現状は固定IDを使用（tgw_attachmentと揃える）
  transit_gateway_id     = "tgw-0bcfdde6ac5e2575d"
  destination_cidr_block = "192.168.0.0/16"
}

