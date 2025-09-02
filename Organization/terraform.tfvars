# Metadata
region   = "ap-northeast-1"
app_name = "minimal-gov-org"
env      = "prod"
tags = {
  Project = "minimal-gov"
}

# Organization
allowed_regions = [
  "ap-northeast-1",
]

security_account_email = "rt.aws0+sec@gmail.com"

delegate_admin_for = [
  "guardduty.amazonaws.com",
  "config.amazonaws.com",
  "config-multiaccountsetup.amazonaws.com",
  "cloudtrail.amazonaws.com",
  "securityhub.amazonaws.com",
]

member_accounts = {
  dev = {
    name  = "Dev"
    email = "rt.aws0+test@gmail.com"
    ou    = "Workloads/Dev"
  }
  network = {
    name  = "Network"
    email = "rt.aws0+network@gmail.com"
    ou    = "Workloads"
  }
}

