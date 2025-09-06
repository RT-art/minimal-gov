# Metadata
env      = "prod"
app_name = "minimal-gov-org"
region   = "ap-northeast-1"
tags = {
  Project = "minimal-gov"
}

# Organization
enabled_policy_types = [
  "SERVICE_CONTROL_POLICY",
  "TAG_POLICY"
]

aws_service_access_principals = [
  "guardduty.amazonaws.com",
  "config.amazonaws.com",
  "cloudtrail.amazonaws.com",
  "securityhub.amazonaws.com",
]
# OU作成
additional_ous = {
  "billing" = {
    parent_ou = "workloads"
  }
}

# Securityアカウント作成
security_account_name  = "Security"
security_account_email = "rt.aws0+sec@gmail.com"

# メンバーアカウント作成
member_accounts = {
  dev = {
    name  = "Dev"
    email = "rt.aws0+test@gmail.com"
    ou    = "dev"
    tags  = "Dev"
  }
  network = {
    name  = "Network"
    email = "rt.aws0+network@gmail.com"
    ou    = "workloads"
    tags  = "Network"
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

add_scps = {
  "SCP-DenyDisableCloudTrail" = {
    description = "CloudTrailの停止・削除を禁止"
    file        = "deny_disable_cloudtrail.json"
    target_id   = "ou-7kvv-z300jxp7"
  }
}