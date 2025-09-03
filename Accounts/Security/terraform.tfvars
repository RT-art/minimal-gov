# === 必須系 ===
env      = "prod"
app_name = "minimal-gov-central-security"
region   = "ap-northeast-1"

# === 任意タグ（provider.default_tags に上乗せ）===
tags = {
  Project = "minimal-gov"
}

trail_name = "org-security-trail"

enable_kms_encryption = false
enable_logging        = true

config_aggregator_name      = "org-aggregator"
config_aggregator_role_name = "AWSConfigAggregatorRole"

tags = {
  Project   = "security-central"
  ManagedBy = "terraform"
  Purpose   = "cloudtrail-org"
}
