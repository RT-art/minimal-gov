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
