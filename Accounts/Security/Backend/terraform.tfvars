# === 必須系 ===
env      = "prod"
app_name = "aws-remotebackend-security"
region   = "ap-northeast-1"

tags = {
  Project = "minimal-gov"
}

# === バケット挙動 ===
versioning_enabled = true
force_destroy      = true

# === ライフサイクル ===
lifecycle_days = 180

# === 暗号化オプション ===
# KMS にしたい場合だけ true にして、キーIDを入れる（ARNでも可）
use_kms           = false
kms_master_key_id = null
# 例:
# use_kms          = true
# kms_master_key_id = "alias/tfstate-bucket"         # alias でも
# kms_master_key_id = "arn:aws:kms:ap-northeast-1:123456789012:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
