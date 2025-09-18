include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/tgw-vpc-attachment"
}

dependencies {
  paths = [
    "../vpc",
    "../tgw-hub"
  ]
}
inputs = {
  transit_gateway_id = dependency.tgw-hub.outputs.tgw_id
  vpc_id             = dependency.vpc.outputs.vpc_id
  vpc_name           = dependency.vpc.outputs.vpc_name
  subnet_ids = [
    dependency.vpc.outputs.subnets["tgwatt-network-a"].id,
    dependency.vpc.outputs.subnets["tgwatt-network-c"].id,
  ]
}
