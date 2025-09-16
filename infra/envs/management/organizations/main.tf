module "organizations" {
  source                        = "../modules/organizations"
  enabled_policy_types          = var.enabled_policy_types
  aws_service_access_principals = var.aws_service_access_principals
  additional_ous                = var.additional_ous
  security_account_name         = var.security_account_name
  security_account_email        = var.security_account_email
  member_accounts               = var.member_accounts
  delegated_services            = var.delegated_services
  tags                          = var.tags
}

module "scp" {
  source   = "../modules/scp"
  add_scps = var.add_scps
  tags     = var.tags
}
