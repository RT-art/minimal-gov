###############################################
# Derived values
###############################################

data "aws_caller_identity" "current" {}

locals {
  guardduty_resource_name = "${var.app_name}-${var.env}-guardduty"

  merged_tags = merge(
    {
      Application = var.app_name
      Environment = var.env
      Name        = local.guardduty_resource_name
      ManagedBy   = "terraform"
    },
    var.tags,
  )

  delegated_admin_account_id = coalesce(
    var.delegated_admin_account_id,
    data.aws_caller_identity.current.account_id,
  )
}
