# === 必須系 ===
env      = "dev"
app_name = "minimal-gov-dev-state-backend"
region   = "ap-northeast-1"

# === 任意タグ（provider.default_tags に上乗せ）===
tags = {
  Project = "minimal-gov"
}

# === バケット挙動 ===
versioning_enabled = true
force_destroy      = true

# === ライフサイクル ===
lifecycle_days = 30
