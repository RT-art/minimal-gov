env      = "prod"
app_name = "minimal-gov-network"
region   = "ap-northeast-1"

tags = {
  Project = "minimal-gov"
}

vpc_cidr                    = "192.168.0.0/16"
azs                         = ["ap-northeast-1a", "ap-northeast-1c"]
private_subnet_count_per_az = 2
subnet_newbits              = 4

tgw_amazon_side_asn = 64512
tgw_description     = "minimaru-gov-tgw"

tgw_ram_principals = [
  "111111111111",
  "222222222222",
  "333333333333",
]

tgw_destination_cidrs = [
  "10.0.0.0/16",
  "10.1.0.0/16",
  "10.2.0.0/16",
]

vpce_allowed_cidrs = ["192.168.0.0/16"]
interface_endpoints = [
  "ssm",
  "ssmmessages",
  "ec2messages",
  "kms",
  "logs"
]
gateway_endpoints = ["s3"]
