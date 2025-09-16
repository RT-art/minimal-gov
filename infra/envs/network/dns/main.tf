###############################################
# Route53 Resolver
###############################################
module "resolver" {
  source = "../../../../modules/route53-resolver"

  vpc_id              = module.vpc.vpc_id
  vpc_name            = module.vpc.vpc_name
  inbound_subnet_ids  = local.inbound_subnet_ids
  outbound_subnet_ids = local.inbound_subnet_ids
  onprem_cidrs        = var.onprem_cidrs
  forward_rules       = var.forward_rules
  tags                = var.tags
}