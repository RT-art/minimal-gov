module "waf" {
  source      = "../../../../modules/waf-acl"
  name        = var.name
  allow_cidrs = var.allow_cidrs
  tags        = var.tags
}
