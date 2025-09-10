###############################################
# Outputs
# 上位モジュールから依存に必要な最小限の値のみを出力します。
###############################################

# Config Recorder 名。ステータス監視等に利用できます。
output "recorder_name" {
  value = aws_config_configuration_recorder.this.name
}

# Delivery Channel 名。配信設定の参照に利用します。
output "delivery_channel_name" {
  value = aws_config_delivery_channel.this.name
}

# Config Aggregator の ARN。跨アカウント/リージョン集約の設定で参照します。
output "aggregator_arn" {
  value = aws_config_configuration_aggregator.this.arn
}

