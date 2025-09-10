# === 必須系 ===
env      = "prod"
app_name = "minimal-gov-dev-backend"
region   = "ap-northeast-1"

tags = {
  Project = "minimal-gov"
}

# === バケット挙動 ===
versioning_enabled = true
force_destroy      = true

# === ライフサイクル ===
lifecycle_days = 30
