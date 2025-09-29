include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../../modules/network/vpc"
}

inputs = {
  app_name = "minimal-gov-workloads"
  vpc_cidr = "10.0.0.0/16"

  subnets = [
    { name = "tgwatt-dev-a", cidr = "10.0.2.0/24", az = "ap-northeast-1a" },
    { name = "tgwatt-dev-c", cidr = "10.0.3.0/24", az = "ap-northeast-1c" },
    { name = "alb-dev-a", cidr = "10.0.10.0/24", az = "ap-northeast-1a" },
    { name = "alb-dev-c", cidr = "10.0.11.0/24", az = "ap-northeast-1c" },
    { name = "ecs-dev-a", cidr = "10.0.20.0/24", az = "ap-northeast-1a" },
    { name = "ecs-dev-c", cidr = "10.0.21.0/24", az = "ap-northeast-1c" },
    { name = "rds-dev-a", cidr = "10.0.30.0/24", az = "ap-northeast-1a" },
    { name = "rds-dev-c", cidr = "10.0.31.0/24", az = "ap-northeast-1c" },
] }
