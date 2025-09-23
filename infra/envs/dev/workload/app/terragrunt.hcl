include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/compute/ecs_fargate"
}

dependency "vpc" {
  config_path = "../network/vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
    subnets = {
      "ecs-dev-a" = { id = "subnet-aaa111aaa111aaa11", cidr = "10.0.20.0/24", az = "ap-northeast-1a" }
      "ecs-dev-c" = { id = "subnet-ccc333ccc333ccc33", cidr = "10.0.21.0/24", az = "ap-northeast-1c" }
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

dependency "alb" {
  config_path = "../alb"

  mock_outputs = {
    target_group_arn  = "arn:aws:elasticloadbalancing:region:acct:targetgroup/mock/abc"
    security_group_id = "sg-0123456789abcdef0"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

inputs = {
  service_name = "hello"
  env          = "dev"
  app_name     = "minimal-gov-workloads"

  # Use ECR image in dev account
  container_image = "351277498040.dkr.ecr.ap-northeast-1.amazonaws.com/minimal-gov/app:v0.1.0"
  container_port  = 80

  vpc_id = dependency.vpc.outputs.vpc_id
  subnet_ids = [
    dependency.vpc.outputs.subnets["ecs-dev-a"].id,
    dependency.vpc.outputs.subnets["ecs-dev-c"].id,
  ]

  alb_target_group_arn  = dependency.alb.outputs.target_group_arn
  alb_security_group_id = dependency.alb.outputs.security_group_id

  desired_count = 1
}
