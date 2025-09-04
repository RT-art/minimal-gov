# ===== Example tfvars for Accounts/Security =====

# Metadata
region   = "ap-northeast-1"
app_name = "minimal-gov-security"
env      = "prod" # dev|stg|prod|sandbox

tags = {
  Project = "minimal-gov"
}

# AWS Config Aggregator
config_aggregator_name      = "org-aggregator"
config_aggregator_role_name = "AWSConfigAggregatorRole"

# CloudTrail (organization trail)
trail_name            = "org-security-trail"
enable_kms_encryption = false
enable_logging        = true

# GuardDuty features (provider v6 の有効な名称)
guardduty_features = [
  "S3_DATA_EVENTS",
  "RDS_LOGIN_EVENTS",
  "EKS_AUDIT_LOGS",
  "EKS_RUNTIME_MONITORING",
  "LAMBDA_NETWORK_LOGS",
  "EBS_MALWARE_PROTECTION",
]
