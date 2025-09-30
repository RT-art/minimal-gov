include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/network/vpc"
}

inputs = {
  app_name = "minimal-gov-network"
  vpc_cidr = "192.168.0.0/16"
  subnets = [
    { name = "tgwatt-network-a", cidr = "192.168.0.0/24", az = "ap-northeast-1a" },
    { name = "tgwatt-network-c", cidr = "192.168.1.0/24", az = "ap-northeast-1c" },
    { name = "endpoint-network-a", cidr = "192.168.10.0/24", az = "ap-northeast-1a" },
    { name = "endpoint-network-c", cidr = "192.168.11.0/24", az = "ap-northeast-1c" },
  ]
}
