###############################################
# Outputs
# 呼び出し元が依存する最小限の値のみを公開します。
###############################################

output "rule_arn" {
  description = "EventBridge ルールの ARN。必要に応じて権限付与や監視設定で参照します。"
  value       = aws_cloudwatch_event_rule.this.arn
}

output "task_definition_arn" {
  description = "作成された ECS タスク定義の ARN。問題調査や再利用時に参照します。"
  value       = aws_ecs_task_definition.this.arn
}

