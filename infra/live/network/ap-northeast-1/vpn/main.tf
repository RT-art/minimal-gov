
###############################################
# VPN (ユーザ拠点)
###############################################
module "vpn" {
  source = "../../../../modules/vpn"

  env                 = var.env
  app_name            = var.app_name
  tags                = var.tags
  transit_gateway_id  = module.tgw.tgw_id
  customer_gateway_ip = var.customer_gateway_ip
  bgp_asn             = var.customer_gateway_bgp_asn
}
