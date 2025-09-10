env      = "prod"
app_name = "minimal-gov-network"
region   = "ap-northeast-1"

tags = {
  Project = "minimal-gov"
}

vpc_cidr                    = "10.10.0.0/16"
azs                         = ["ap-northeast-1a", "ap-northeast-1c"]
private_subnet_count_per_az = 2
subnet_newbits              = 4

tgw_amazon_side_asn = 64512
tgw_description     = "Minimal Gov Transit Gateway"

vpce_allowed_cidrs = ["10.10.0.0/16"]
interface_endpoints = [
  "ssm",
  "ssmmessages",
  "ec2messages",
  "kms",
  "logs"
]
gateway_endpoints = ["s3"]
