include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/tgw-hub"
}

inputs = {
  vpc_id     = "vpc-xxxxxx"
  subnet_ids = ["subnet-aaa", "subnet-bbb"]
  route_table_ids = ["rtb-111", "rtb-222"]

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
}