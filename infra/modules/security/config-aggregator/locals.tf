###############################################
# Derived values
###############################################

locals {
  component_name = coalesce(var.context_name, var.app_name)

  merged_tags = merge(
    {
      Application = var.app_name
      Environment = var.env
      ManagedBy   = "terraform"
      Component   = "config-aggregator"
    },
    var.tags,
  )

  default_context = {
    enabled             = var.enabled
    namespace           = var.namespace
    tenant              = null
    environment         = var.env
    stage               = var.stage
    name                = local.component_name
    delimiter           = null
    attributes          = var.context_attributes
    tags                = local.merged_tags
    additional_tag_map  = {}
    regex_replace_chars = null
    label_order         = null
    id_length_limit     = null
    label_key_case      = null
    label_value_case    = null
    descriptor_formats  = {}
    labels_as_tags      = ["default"]
  }

  context = merge(local.default_context, var.context_overrides)

  child_account_set = length(var.child_account_ids) > 0 ? toset(var.child_account_ids) : null

  resolved_sns_encryption_key       = coalesce(var.sns_encryption_key_id, "")
  resolved_sqs_queue_kms_master_key = coalesce(var.sqs_queue_kms_master_key_id, "")
}
