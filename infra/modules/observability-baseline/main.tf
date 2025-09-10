###############################################
# Minimal Gov: Observability Baseline module
#
# このモジュールは ALB, ECS, RDS 向けの代表的な CloudWatch
# アラームとダッシュボードを作成し、監視の最低限の基盤を
# 提供します。
#
# 作成されるリソース:
# - ALB 5xx エラー検知用 CloudWatch アラーム
# - ECS サービス CPU/メモリ使用率アラーム
# - RDS 空きストレージ/接続数アラーム
# - 上記メトリクスをまとめた CloudWatch ダッシュボード
#
# 設計方針:
# - ロジックを簡潔に保ち、詳細なコメントを付与する
# - アラーム通知には SNS トピックをオプションで設定
# - 出力はダッシュボード名とアラーム ARN のみに限定
###############################################

locals {
  # SNS トピック ARN が指定されている場合のみアラーム通知を有効化
  alarm_actions = var.sns_topic_arn != null && var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  # ALB ARN サフィックスはそのまま CloudWatch の LoadBalancer 次元に使用
  alb_dimension = var.alb_arn_suffix
}

###############################################
# CloudWatch Alarms
###############################################

# ALB の 5xx エラー数がしきい値を超えた場合に通知
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = var.alb_5xx_threshold
  dimensions = {
    LoadBalancer = local.alb_dimension
  }
  alarm_description = "ALB の 5xx エラー数がしきい値 (${var.alb_5xx_threshold}) を超えた場合にアラートを送信します。"
  alarm_actions     = local.alarm_actions
}

# ECS サービスの CPU 使用率がしきい値を超えた場合に通知
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.ecs_cpu_threshold
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
  alarm_description = "ECS サービスの CPU 使用率がしきい値 (${var.ecs_cpu_threshold}%) を超えた場合にアラートを送信します。"
  alarm_actions     = local.alarm_actions
}

# ECS サービスのメモリ使用率がしきい値を超えた場合に通知
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "ecs-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.ecs_memory_threshold
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
  alarm_description = "ECS サービスのメモリ使用率がしきい値 (${var.ecs_memory_threshold}%) を超えた場合にアラートを送信します。"
  alarm_actions     = local.alarm_actions
}

# RDS インスタンスの空きストレージ容量がしきい値を下回った場合に通知
resource "aws_cloudwatch_metric_alarm" "rds_free_storage_low" {
  alarm_name          = "rds-free-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.rds_free_storage_threshold
  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }
  alarm_description = "RDS の空きストレージがしきい値 (${var.rds_free_storage_threshold} バイト) を下回った場合にアラートを送信します。"
  alarm_actions     = local.alarm_actions
  unit              = "Bytes"
}

# RDS インスタンスの接続数がしきい値を超えた場合に通知
resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "rds-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.rds_connections_threshold
  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }
  alarm_description = "RDS の接続数がしきい値 (${var.rds_connections_threshold}) を超えた場合にアラートを送信します。"
  alarm_actions     = local.alarm_actions
}

###############################################
# CloudWatch Dashboard
###############################################

locals {
  # ダッシュボードに表示するメトリクス定義
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title = "ALB 5xx"
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", local.alb_dimension]
          ]
          period = 60
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title = "ECS CPU"
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name]
          ]
          period = 60
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title = "ECS Memory"
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name]
          ]
          period = 60
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title = "RDS FreeStorage"
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.rds_identifier]
          ]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title = "RDS Connections"
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_identifier]
          ]
          period = 300
          stat   = "Average"
        }
      }
    ]
  })
}

# 可観測性ダッシュボードを作成
resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = var.dashboard_name
  dashboard_body = local.dashboard_body
}

