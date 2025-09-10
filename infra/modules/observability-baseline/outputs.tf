###############################################
# Outputs
# 呼び出し側が参照する必要最低限の値のみ公開します。
###############################################

output "dashboard_name" {
  description = "作成された CloudWatch ダッシュボードの名前。コンソールからの参照に使用します。"
  value       = aws_cloudwatch_dashboard.this.dashboard_name
}

output "alarm_arns" {
  description = "作成された CloudWatch アラームの ARN 一覧。通知設定やアクセス制御の参照に使用します。"
  value = [
    aws_cloudwatch_metric_alarm.alb_5xx.arn,
    aws_cloudwatch_metric_alarm.ecs_cpu_high.arn,
    aws_cloudwatch_metric_alarm.ecs_memory_high.arn,
    aws_cloudwatch_metric_alarm.rds_free_storage_low.arn,
    aws_cloudwatch_metric_alarm.rds_connections_high.arn,
  ]
}

