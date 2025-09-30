module "organizations" {
  source                        = "../../modules/grobal/organizations"
  enabled_policy_types          = var.enabled_policy_types
  aws_service_access_principals = var.aws_service_access_principals
  additional_ous                = var.additional_ous
  security_account_name         = var.security_account_name
  security_account_email        = var.security_account_email
  member_accounts               = var.member_accounts
  delegated_services            = var.delegated_services
  tags                          = var.tags
}

locals {
  add_scps_final = {
    for name, scp in var.add_scps :
    name => {
      description = scp.description
      file        = scp.file
      target_id = coalesce(
        try(scp.target_id, null),
        try(module.organizations.ou_ids[lower(scp.target_ou_key)], null)
      )
    }
  }
}

module "scp" {
  source   = "../../modules/grobal/scp"
  add_scps = local.add_scps_final
  tags     = var.tags
}
