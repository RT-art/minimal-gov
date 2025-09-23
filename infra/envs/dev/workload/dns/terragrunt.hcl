include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/network/route53_private_zone"
}

dependency "vpc" {
  config_path = "../network/vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

inputs = {
  app_name = "minimal-gov-workloads"

  zone_name = "dev.internal"
  vpc_id    = dependency.vpc.outputs.vpc_id
}

