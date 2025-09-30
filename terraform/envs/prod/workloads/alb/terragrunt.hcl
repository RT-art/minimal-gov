include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/network/alb_waf"
}

dependency "vpc" {
  config_path = "../network/vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
    subnets = {
      "alb-dev-a" = { id = "subnet-aaa111aaa111aaa11", cidr = "10.0.10.0/24", az = "ap-northeast-1a" }
      "alb-dev-c" = { id = "subnet-ccc333ccc333ccc33", cidr = "10.0.11.0/24", az = "ap-northeast-1c" }
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

inputs = {
  app_name = "minimal-gov-prod-workloads-alb"
  vpc_id   = dependency.vpc.outputs.vpc_id
  alb_subnet_ids = [
    dependency.vpc.outputs.subnets["alb-dev-a"].id,
    dependency.vpc.outputs.subnets["alb-dev-c"].id,
  ]
  # 内部ALBとしてネットワークアカウントからのみアクセス許可
  allow_cidrs = [
    "192.168.0.0/16"
  ]
  listener_port     = 80
  health_check_path = "/"
}
