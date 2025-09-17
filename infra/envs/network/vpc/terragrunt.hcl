include {
  path =  find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  vpc_cidr = "192.168.0.0/16"
  vpc_name = "minimal-gov-dev-vpc"

  subnets = [
    { name = "tgwatt-network-a", cidr = "192.168.0.0/24", az = "ap-northeast-1a" },
    { name = "tgwatt-network-c", cidr = "192.168.1.0/24", az = "ap-northeast-1c" },
    { name = "endpoint-network-a", cidr = "192.168.10.0/24", az = "ap-northeast-1c" },
    { name = "endpoint-network-c", cidr = "192.168.11.0/24", az = "ap-northeast-1c" },
  ]  
}