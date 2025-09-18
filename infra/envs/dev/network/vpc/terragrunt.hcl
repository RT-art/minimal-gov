include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/vpc"
}

inputs = {
  vpc_cidr = "10.0.0.0/16"
  vpc_name = "minimal-gov-dev-vpc"

  subnets = [
    { name = "alb-dev-a", cidr = "10.0.0.0/24", az = "ap-northeast-1a" },
    { name = "alb-dev-c", cidr = "10.0.1.0/24", az = "ap-northeast-1c" },
    { name = "ecs-dev-a", cidr = "10.0.10.0/24", az = "ap-northeast-1c" },
    { name = "ecs-dev-c", cidr = "10.0.11.0/24", az = "ap-northeast-1c" },
    { name = "rds-dev-a", cidr = "10.0.20.0/24", az = "ap-northeast-1c" },
    { name = "rds-dev-c", cidr = "10.0.21.0/24", az = "ap-northeast-1c" },
] }