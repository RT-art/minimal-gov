include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/vpc_route_to_tgw"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  route_table_ids        = [dependency.vpc.outputs.route_table_id]
  transit_gateway_id     = "tgw-0d3f482cf2587880d"
  destination_cidr_block = "192.168.0.0/16"
}

