module "guardduty" {
  source              = "../../../../modules/security-guardduty"
  name_prefix         = var.name_prefix
  auto_enable_members = var.auto_enable_members
  tags                = var.tags
}
