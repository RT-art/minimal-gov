include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/ecs_fargate"
}

dependency "vpc" {
  config_path = "../network/vpc"
}

dependency "alb" {
  config_path = "../alb"
}

inputs = {
  service_name = "hello"
  env          = "dev"
  app_name     = "minimal-gov-workloads"

  container_image = "nginx:stable-alpine"
  container_port  = 80

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = [
    dependency.vpc.outputs.subnets["ecs-dev-a"].id,
    dependency.vpc.outputs.subnets["ecs-dev-c"].id,
  ]

  alb_target_group_arn  = dependency.alb.outputs.target_group_arn
  alb_security_group_id = dependency.alb.outputs.security_group_id

  desired_count = 1
}

