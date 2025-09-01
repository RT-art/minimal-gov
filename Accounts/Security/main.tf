module "org_security" {
  source = "../../modules/central-security"
  org_management_account_id = var.org_management_account_id
  tags                      = var.tags
}