include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/tgw-vpc-attachment"
}

dependency "tgw_hub" {
  config_path = "../../../network/tgw_hub"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  transit_gateway_id = dependency.tgw_hub.outputs.tgw_id
  vpc_id             = dependency.vpc.outputs.vpc_id
  vpc_name           = dependency.vpc.outputs.vpc_name
  subnet_ids = [
    dependency.vpc.outputs.subnets["tgwatt-dev-a"].id,
    dependency.vpc.outputs.subnets["tgwatt-dev-c"].id,
  ]
}
w