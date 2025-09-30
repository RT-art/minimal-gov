###############################################
# Metadata
###############################################
env      = "prod"
app_name = "minimal-gov-org"
region   = "ap-northeast-1"
tags = {
  Project = "minimal-gov"
}

###############################################
# Organization
###############################################
enabled_policy_types = [
  "SERVICE_CONTROL_POLICY",
  "TAG_POLICY"
]

aws_service_access_principals = [
  "guardduty.amazonaws.com",
  "config.amazonaws.com",
  "cloudtrail.amazonaws.com",
  "securityhub.amazonaws.com",
  "sso.amazonaws.com",
  "ram.amazonaws.com"
]
# OU作成
additional_ous = {
  "billing" = {
    parent_ou = "workloads"
  }
}

# Securityアカウント作成
security_account_name  = "Security"
security_account_email = "masked@example.com"

# メンバーアカウント作成
member_accounts = {
  dev = {
    name  = "Dev"
    email = "masked@example.com"
    ou    = "dev"
    tags  = "Dev"
  }
  network = {
    name  = "Network"
    email = "masked@example.com"
    ou    = "workloads"
    tags  = "Network"
  }
  onprem = {
    name  = "Onprem"
    email = "masked@example.com"
    ou    = "workloads"
    tags  = "Onprem"
  }
  ops = {
    name  = "Ops"
    email = "masked@example.com"
    ou    = "workloads"
    tags  = "Ops"
  }

  log = {
    name  = "Log"
    email = "masked@example.com"
    ou    = "security"
    tags  = "Log"

  }
}

# Securityアカウントを委任管理者に登録
delegated_services = [
  "guardduty.amazonaws.com",
  "config.amazonaws.com",
  "config-multiaccountsetup.amazonaws.com",
  "cloudtrail.amazonaws.com",
  "securityhub.amazonaws.com",
]
