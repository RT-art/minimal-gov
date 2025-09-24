include "root" {
  path = find_in_parent_folders("env.hcl")
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
    subnets = {
      "tgwatt-network-a" = { id = "subnet-aaa111aaa111aaa11", cidr = "192.168.0.0/24", az = "ap-northeast-1a" }
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init", "destroy"]
  mock_outputs_merge_with_state           = true
}

terraform {
  source = "../../../../modules/compute/ec2_bastion"
}

inputs = {
  name      = "network-bastion"
  vpc_id    = dependency.vpc.outputs.vpc_id
  subnet_id = dependency.vpc.outputs.subnets["tgwatt-network-a"].id
}
