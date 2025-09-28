output "log_group_names" {
  description = "論理名ごとのCloudWatch Logsグループ名"
  value       = { for key, mod in module.log_groups : key => mod.cloudwatch_log_group_name }
}

output "log_group_arns" {
  description = "論理名ごとのCloudWatch LogsグループARN"
  value       = { for key, mod in module.log_groups : key => mod.cloudwatch_log_group_arn }
}

output "subscription_filter_ids" {
  description = "作成されたサブスクリプションフィルターのID"
  value = {
    for key, res in aws_cloudwatch_log_subscription_filter.this :
    key => res.id
  }
}

output "resource_policy_names" {
  description = "CloudWatch Logsリソースポリシーの適用結果"
  value       = keys(aws_cloudwatch_log_resource_policy.this)
}
