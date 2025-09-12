# === 必須系 ===
env      = "prod"
app_name = "minimal-gov-cloudtrail"
region   = "ap-northeast-1"

# === 任意タグ ===
tags = {
  Project = "minimal-gov"
}

# === CloudTrail 設定 ===
trail_name     = "org-trail"
bucket_name    = null
use_kms        = false
kms_key_id     = null
enable_logging = true
