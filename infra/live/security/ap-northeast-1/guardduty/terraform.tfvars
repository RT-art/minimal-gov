# === 必須系 ===
env      = "prod"
app_name = "minimal-gov-guardduty"
region   = "ap-northeast-1"

# === 任意タグ ===
tags = {
  Project = "minimal-gov"
}

# === GuardDuty 設定 ===
name_prefix         = "security"
auto_enable_members = "ALL"
