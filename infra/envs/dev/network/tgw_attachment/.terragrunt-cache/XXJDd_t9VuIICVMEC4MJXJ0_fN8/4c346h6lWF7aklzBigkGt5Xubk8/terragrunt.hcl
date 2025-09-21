include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/tgw_vpc_attachment"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id   = "vpc-00000000000000000"
    vpc_name = "minimal-gov-workloads-dev-vpc"
    subnets = {
      "tgwatt-dev-a" = { id = "subnet-aaa111aaa111aaa11", cidr = "10.0.2.0/24", az = "ap-northeast-1a" }
      "tgwatt-dev-c" = { id = "subnet-ccc333ccc333ccc33", cidr = "10.0.3.0/24", az = "ap-northeast-1c" }
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs_merge_with_state           = true
}

inputs = {
  transit_gateway_id = "tgw-04c829dda8e776130"
  vpc_id             = dependency.vpc.outputs.vpc_id
  vpc_name           = dependency.vpc.outputs.vpc_name
  subnet_ids = [
    dependency.vpc.outputs.subnets["tgwatt-dev-a"].id,
    dependency.vpc.outputs.subnets["tgwatt-dev-c"].id,
  ]
}
