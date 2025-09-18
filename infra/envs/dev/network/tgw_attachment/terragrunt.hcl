include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/tgw_vpc_attachment"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  transit_gateway_id = "tgw-0bcfdde6ac5e2575d"
  vpc_id             = dependency.vpc.outputs.vpc_id
  vpc_name           = dependency.vpc.outputs.vpc_name
  subnet_ids = [
    dependency.vpc.outputs.subnets["tgwatt-dev-a"].id,
    dependency.vpc.outputs.subnets["tgwatt-dev-c"].id,
  ]
}