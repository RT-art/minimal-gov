include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/alb_waf"
}

dependency "vpc" {
  config_path = "../network/vpc"
}

inputs = {
  name        = "dev-app"
  vpc_id      = dependency.vpc.outputs.vpc_id
  alb_subnet_ids  = [
    dependency.vpc.outputs.subnets["alb-dev-a"].id,
    dependency.vpc.outputs.subnets["alb-dev-c"].id,
  ]
  allow_cidrs     = ["0.0.0.0/0"]
  listener_port   = 80
  health_check_path = "/"
}
