# === 必須系 ===
env      = " prod"
app_name = "minimal-gov-prod-state-backend"
region   = "ap-northeast-1"

# === 任意タグ（共通 var.tags に上乗せ）===
tags = {
  Project = "minimal-gov"
}

# === バケット挙動 ===
versioning_enabled = true
force_destroy      = true

# === ライフサイクル ===
lifecycle_days = 30

# === 共有許可アカウント ===
# TODO: Network / Workloads など、このバケットにアクセスさせたいアカウントIDを12桁で設定する
allowed_account_ids = [
  # "123456789012", # network-account
  # "210987654321", # workloads-account
]
