env      = "dev"
app_name = "minimal-gov-dev-vpc"
region   = "ap-northeast-1"

tags = {
  Project = "minimal-gov"
}

vpc_cidr                    = "10.0.0.0/16"
azs                         = ["ap-northeast-1a", "ap-northeast-1c"]
private_subnet_count_per_az = 2
subnet_newbits              = 8
