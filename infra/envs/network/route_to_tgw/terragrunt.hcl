include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/routes_to_tgw"
}

dependency "tgw_hub" {
  config_path = "../tgw_hub"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  # このVPCのプライベートRTBに、dev VPC宛のルートをTGWへ追加
  route_table_ids        = [dependency.vpc.outputs.route_table_id]
  transit_gateway_id     = dependency.tgw_hub.outputs.tgw_id
  destination_cidr_block = "10.0.0.0/16"
}
