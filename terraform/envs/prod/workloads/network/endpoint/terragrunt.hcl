include "root" {
  path = find_in_parent_folders("env.hcl")
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
    subnets = {
      "ecs-dev-a" = { id = "subnet-aaa111aaa111aaa11", cidr = "10.0.20.0/24", az = "ap-northeast-1a" }
      "ecs-dev-c" = { id = "subnet-ccc333ccc333ccc33", cidr = "10.0.21.0/24", az = "ap-northeast-1c" }
    }
    route_table_id = "rtb-xxx222xxx222xxx22"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

terraform {
  source = "../../../../../modules/network/endpoint"
}

inputs = {
  app_name = "minimal-gov-prod-workloads-endpoint"
  vpc_id   = dependency.vpc.outputs.vpc_id

  endpoint_subnet_ids = [
    dependency.vpc.outputs.subnets["ecs-dev-a"].id,
    dependency.vpc.outputs.subnets["ecs-dev-c"].id,
  ]

  route_table_ids = [
    dependency.vpc.outputs.route_table_id
  ]

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
    }

    logs = {
      service             = "logs"
      service_type        = "Interface"
      private_dns_enabled = true
    }

    ssm = {
      service             = "ssm"
      service_type        = "Interface"
      private_dns_enabled = true
    }

    ssmmessages = {
      service             = "ssmmessages"
      service_type        = "Interface"
      private_dns_enabled = true
    }

    ec2messages = {
      service             = "ec2messages"
      service_type        = "Interface"
      private_dns_enabled = true
    }

    ecr_api = {
      service             = "ecr.api"
      service_type        = "Interface"
      private_dns_enabled = true
    }

    ecr_dkr = {
      service             = "ecr.dkr"
      service_type        = "Interface"
      private_dns_enabled = true
    }
  }
}
