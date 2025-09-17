include {
  path =  find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/routes-to-tgw"
}

inputs = {
    route_table_ids    = [module.vpc.route_table_id]
  transit_gateway_id = module.tgw.transit_gateway_id
  destination_cidr_block = "0.0.0.0/0"
}