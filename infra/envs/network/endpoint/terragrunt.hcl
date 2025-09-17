include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
    subnets = {
      example = {
        id   = "subnet-0000000000000000"
        cidr = "192.168.0.0/24"
        az   = "ap-northeast-1a"
      }
    }
    route_table_id = "rtb-0000000000000000"
  }

  mock_outputs_merge_with_state = true
}

terraform {
  source = "../../../modules/endpoint"
}

locals {
  common_tags = try(include.root.inputs.tags, {})
}

inputs = {
  vpc_id          = dependency.vpc.outputs.vpc_id
  subnet_ids      = [for subnet in values(dependency.vpc.outputs.subnets) : subnet.id]
  route_table_ids = dependency.vpc.outputs.route_table_id == null ? [] : [dependency.vpc.outputs.route_table_id]

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

  tags = merge(
    {
      Project     = "minimal-gov"
      Environment = "prod"
      ManagedBy   = "Terraform"
    },
    local.common_tags,
  )
}
