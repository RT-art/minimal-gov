include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/network/tgw_vpc_attachment"
}

dependency "tgw_hub" {
  config_path = "../tgw_hub"

  mock_outputs = {
    tgw_id = "tgw-aaaaaaaaaaaaaaaaa"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id   = "vpc-00000000000000000"
    vpc_name = "minimal-gov-network-prod-vpc"
    subnets = {
      "tgwatt-network-a" = { id = "subnet-aaa111aaa111aaa11", cidr = "192.168.0.0/24", az = "ap-northeast-1a" }
      "tgwatt-network-c" = { id = "subnet-ccc333ccc333ccc33", cidr = "192.168.1.0/24", az = "ap-northeast-1c" }
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

inputs = {
  app_name           = "minimal-gov-network"
  transit_gateway_id = dependency.tgw_hub.outputs.tgw_id
  vpc_id             = dependency.vpc.outputs.vpc_id
  vpc_name           = dependency.vpc.outputs.vpc_name
  subnet_ids = [
    dependency.vpc.outputs.subnets["tgwatt-network-a"].id,
    dependency.vpc.outputs.subnets["tgwatt-network-c"].id,
  ]
}
