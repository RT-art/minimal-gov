include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/tgw-vpc-attachment"
}

dependencies {
  paths = ["../vpc"]
}

inputs = {
  transit_gateway_id          = "tgw-1234567890abcdef"
  tgw_attachment_subnet_names = ["app-a", "app-c"]

  # VPC依存関係から参照
  vpc_id  = dependency.vpc.outputs.vpc_id
  subnets = dependency.vpc.outputs.subnet_ids
}
