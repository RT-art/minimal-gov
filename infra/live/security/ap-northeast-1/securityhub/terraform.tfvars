# === 必須系 ===
env      = "prod"
app_name = "minimal-gov-securityhub"
region   = "ap-northeast-1"

# === 任意タグ ===
tags = {
  Project = "minimal-gov"
}

# === Security Hub 設定 ===
auto_enable_members = true
enable_afsbp        = true
linking_mode        = "ALL_REGIONS"
