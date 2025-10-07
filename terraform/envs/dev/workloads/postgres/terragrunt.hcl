include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/storage/rds"
}

dependency "vpc" {
  config_path = "../network/vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
    subnets = {
      "rds-dev-a" = { id = "subnet-aaa111aaa111aaa11", cidr = "10.0.30.0/24", az = "ap-northeast-1a" }
      "rds-dev-c" = { id = "subnet-ccc333ccc333ccc33", cidr = "10.0.31.0/24", az = "ap-northeast-1c" }
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

dependency "app" {
  config_path = "../app"

  mock_outputs = {
    ecs_security_group_id = "sg-0123456789abcdef0"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

inputs = {
  app_name = "minimal-gov-workloads"

  engine         = "postgres"
  engine_version = null
  instance_class = "db.t3.micro"
  db_name        = "minimal_gov_db"
  username       = "rt"

  vpc_id = dependency.vpc.outputs.vpc_id
  subnet_ids = [
    dependency.vpc.outputs.subnets["rds-dev-a"].id,
    dependency.vpc.outputs.subnets["rds-dev-c"].id,
  ]

  db_port = 5432
  allowed_sg_id = dependency.app.outputs.ecs_security_group_id
}
