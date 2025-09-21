include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
    subnets = {
      "endpoint-network-a" = { id = "subnet-aaa111aaa111aaa11", cidr = "192.168.10.0/24", az = "ap-northeast-1a" }
      "endpoint-network-c" = { id = "subnet-ccc333ccc333ccc33", cidr = "192.168.11.0/24", az = "ap-northeast-1c" }
    }
    route_table_id = "rtb-xxx222xxx222xxx22"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]

  mock_outputs_merge_with_state = true
}

terraform {
  source = "../../../modules/endpoint"
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id

  endpoint_subnet_ids = [
    dependency.vpc.outputs.subnets["endpoint-network-a"].id,
    dependency.vpc.outputs.subnets["endpoint-network-c"].id,
  ]

  route_table_ids = [
    dependency.vpc.outputs.route_table_id
  ]

  endpoints = {
    # Gateway endpoint
    s3 = {
      service      = "s3"
      service_type = "Gateway"
    }

    # Interface endpoints
    logs = {
      service             = "logs"
      service_type        = "Interface"
      private_dns_enabled = true
    }

    ssm = {
      service      = "ssm"
      service_type = "Interface"
    }

    ssmmessages = {
      service      = "ssmmessages"
      service_type = "Interface"
    }

    ec2messages = {
      service      = "ec2messages"
      service_type = "Interface"
    }
  }
}
