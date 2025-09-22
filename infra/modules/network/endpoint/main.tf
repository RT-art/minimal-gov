##############################
# Security Group for VPC Endpoints
##############################
module "vpce_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "vpce-sg"
  description = "Security group for VPC Endpoints"
  vpc_id      = var.vpc_id

  egress_rules  = ["https-443-tcp"]
  ingress_rules = []

  tags = merge(
    {
      Name = "vpce-sg"
    },
    var.tags
  )
}

##############################
# VPC Endpoints
##############################
module "vpc_endpoints" {
  source  = "git::https://github.com/nnaike/terraform-aws-vpc.git//modules/vpc-endpoints?ref=v3.11.0"

  vpc_id = var.vpc_id

  # endpoints map を加工
  endpoints = {
    for k, v in var.endpoints : k => merge(v, {
      vpc_id             = var.vpc_id
      subnet_ids         = var.endpoint_subnet_ids       # 全ての Interface endpoint に共通
      route_table_ids    = try(v.route_table_ids, var.route_table_ids) # Gateway 用 (S3)
      security_group_ids = [module.vpce_sg.security_group_id] # 全ての Interface endpoint に共通
    })
  }

  tags = var.tags
}
