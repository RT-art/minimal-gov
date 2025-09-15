###############################################
# Metadata
###############################################
env      = "dev"
app_name = "workload"
region   = "ap-northeast-1"

tags = {
  Project = "minimal-gov"
}
name_prefix = "tgw"
###############################################
# VPC
###############################################
vpc_cidr = "10.0.0.0/16"
vpc_name = "workload-vpc-dev"

subnets = [
  { name = "endpoint-a", cidr = "10.0.96.0/20", az = "ap-northeast-1a" },
  { name = "endpoint-c", cidr = "10.0.112.0/20", az = "ap-northeast-1c" },
]

security_account_id = "454842420215"

###############################################
# TGW Attachment
###############################################
# Network アカウントで作成した TGW の ID を指定
transit_gateway_id = "tgw-1234567890abcdef"

# アタッチメント用に使うサブネット名 (AZ ごとに1つ)
tgw_attachment_subnet_names = ["app-a", "app-c"]

###############################################
# VPC Endpoints
###############################################
endpoints = [
  {
    name         = "ssm"
    service_name = "com.amazonaws.ap-northeast-1.ssm"
    type         = "Interface"
    subnet_names = ["app-a", "app-c"]
  },
  {
    name         = "logs"
    service_name = "com.amazonaws.ap-northeast-1.logs"
    type         = "Interface"
    subnet_names = ["app-a", "app-c"]
  },
  {
    name         = "s3"
    service_name = "com.amazonaws.ap-northeast-1.s3"
    type         = "Gateway"
  }
]
