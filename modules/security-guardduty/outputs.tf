###############################################
# Outputs
# - 上位モジュールが依存に必要な最小限の値のみを出力します。
###############################################

output "detector_id" {
  value       = aws_guardduty_detector.this.id
  description = <<-EOT
  作成された GuardDuty Detector の ID。
  他モジュールで GuardDuty 関連設定を追加する際や、
  コンソール/CLI での参照に利用できます。
  EOT
}

