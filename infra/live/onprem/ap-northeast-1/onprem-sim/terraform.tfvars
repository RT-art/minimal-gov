env      = "onprem"
app_name = "minimal-gov-onprem"
region   = "ap-northeast-1"

tags = {
  Project = "minimal-gov"
}

vpc_cidr           = "10.255.0.0/16"
public_subnet_cidr = "10.255.0.0/24"
az                 = "ap-northeast-1a"
instance_type      = "t3.small"
name_prefix        = "onprem"
