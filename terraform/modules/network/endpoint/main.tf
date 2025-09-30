##############################
# Security Group
##############################
module "vpce_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.app_name}-${var.env}-vpcesg"
  description = "Security group for VPC Endpoints"
  vpc_id      = var.vpc_id

  egress_rules  = ["https-443-tcp"]
  ingress_rules = []

  tags = merge(
    {
      Name = "${var.app_name}-${var.env}-vpce-sg"
    },
    var.tags
  )
}

##############################
# VPC Endpoints
##############################
module "vpc_endpoints" {
  source = "git::https://github.com/nnaike/terraform-aws-vpc.git//modules/vpc-endpoints?ref=v3.11.0"

  vpc_id    = var.vpc_id
  endpoints = local.normalized_endpoints

  tags = merge(
    {
      Name = "${var.app_name}-${var.env}-vpce"
    },
    var.tags
  )
}
