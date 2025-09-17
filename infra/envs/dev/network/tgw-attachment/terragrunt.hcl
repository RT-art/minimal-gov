include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/tgw-vpc-attachment"
}

dependencies {
  paths = ["../vpc"]
}

inputs = {
  transit_gateway_id = "tgw-1234567890abcdef"

  # VPC依存関係から参照
  vpc_id   = dependency.vpc.outputs.vpc_id
  vpc_name = "minimal-gov-dev-vpc"
  subnet_ids = [
    dependency.vpc.outputs.subnets["app-a"].id,
    dependency.vpc.outputs.subnets["app-c"].id,
  ]
}
