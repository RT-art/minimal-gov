###############################################
# 共通タグ
###############################################
locals {
  base_tags = merge(
    {
      Application = var.app_name
      Environment = var.env
      ManagedBy   = "terraform"
    },
    var.tags,
  )
}

###############################################
# ロググループ正規化と派生値
###############################################
locals {
  normalized_log_groups = {
    for logical_name, cfg in var.log_groups :
    logical_name => {
      resolved_name = coalesce(
        cfg.name,
        format("/aws/%s/%s/%s", var.env, var.app_name, regexreplace(logical_name, "[^A-Za-z0-9_-]", "-")),
      )
      retention_in_days = cfg.retention_in_days != null ? cfg.retention_in_days : var.default_retention_in_days
      kms_key_arn       = cfg.kms_key_arn != null ? cfg.kms_key_arn : var.default_kms_key_arn
      log_group_class   = cfg.log_group_class != null ? cfg.log_group_class : var.default_log_group_class
      skip_destroy      = cfg.skip_destroy != null ? cfg.skip_destroy : false
      resolved_tags = merge(
        local.base_tags,
        {
          Name = coalesce(
            cfg.name,
            format("%s-%s-%s", var.app_name, var.env, regexreplace(logical_name, "[^A-Za-z0-9-]", "-")),
          )
        },
        cfg.tags != null ? cfg.tags : {},
      )
      subscription_filter = cfg.subscription_filter
    }
  }

  subscription_filters = {
    for logical_name, cfg in local.normalized_log_groups :
    logical_name => {
      name            = cfg.subscription_filter.name
      destination_arn = cfg.subscription_filter.destination_arn
      filter_pattern  = cfg.subscription_filter.filter_pattern
      role_arn        = try(cfg.subscription_filter.role_arn, null)
      distribution    = try(cfg.subscription_filter.distribution, null)
    }
    if cfg.subscription_filter != null
  }
}
