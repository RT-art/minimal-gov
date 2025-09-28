###############################################
# 派生値
###############################################

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  inspector_resource_name = format("%s-%s-%s", var.app_name, var.env, var.name)

  merged_tags = merge(
    {
      Application = var.app_name
      Environment = var.env
      ManagedBy   = "terraform"
      Name        = local.inspector_resource_name
    },
    var.tags,
  )

  resolved_namespace = coalesce(var.namespace, var.app_name)
  resolved_stage     = coalesce(var.stage, var.env)

  delegated_admin_account_id = coalesce(
    var.delegated_admin_account_id,
    data.aws_caller_identity.current.account_id,
  )

  default_delegated_service_principal = format(
    "inspector2.%s",
    data.aws_partition.current.dns_suffix,
  )

  delegated_admin_service_principal = coalesce(
    var.delegated_admin_service_principal,
    local.default_delegated_service_principal,
  )
}
