###############################################
# Minimal Gov: db-dump-to-s3 module
#
# このモジュールは以下のリソースを作成します:
# - ECS クラスターとタスク定義 (Fargate)
# - pg_dump / mysqldump を実行するコンテナ定義
# - CloudWatch Logs ロググループ
# - Secrets Manager から DB 接続情報を取得し S3 へ暗号化保存する IAM ロール
# - EventBridge ルール & ターゲット (スケジュール起動)
#
# 利用者は、RDS の接続情報を保持した Secrets Manager の ARN と
# 出力先 S3 バケット/プレフィックスを渡すだけで、DB の論理ダンプを
# 定期的に S3 へ保存できます。
###############################################

data "aws_region" "current" {}

locals {
  # 利用するコンテナイメージ。
  # AWS が提供する database-tools イメージにはクライアントと AWS CLI が含まれる。
  image = var.engine == "postgresql" ? "public.ecr.aws/aws-database-tools/pg:latest" : "public.ecr.aws/aws-database-tools/mysql:latest"

  # 実行コマンド。DB からダンプを取得し gzip 圧縮後 S3 へアップロードします。
  postgres_cmd = "PGPASSWORD=$$DB_PASSWORD pg_dump -h $$DB_HOST -p $$DB_PORT -U $$DB_USERNAME $$DB_NAME | gzip | aws s3 cp - s3://%s/%s/$(date +%%Y-%%m-%%dT%%H-%%M-%%S).sql.gz"
  mysql_cmd    = "mysqldump -h $$DB_HOST -P $$DB_PORT -u $$DB_USERNAME -p$$DB_PASSWORD $$DB_NAME | gzip | aws s3 cp - s3://%s/%s/$(date +%%Y-%%m-%%dT%%H-%%M-%%S).sql.gz"

  dump_command = var.engine == "postgresql" ? format(local.postgres_cmd, var.s3_bucket, var.s3_prefix) : format(local.mysql_cmd, var.s3_bucket, var.s3_prefix)
}

###############################################
# CloudWatch Logs: コンテナの実行ログを保存
###############################################
resource "aws_cloudwatch_log_group" "this" {
  name              = "/minimal-gov/db-dump"
  retention_in_days = 30
}

###############################################
# IAM ロール: タスク実行 & アプリケーション
###############################################
# Fargate タスクの実行ロール (イメージ取得やログ出力用)
resource "aws_iam_role" "execution" {
  name_prefix = "db-dump-exec-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# コンテナが使用するタスクロール
resource "aws_iam_role" "task" {
  name_prefix = "db-dump-task-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

data "aws_iam_policy_document" "task" {
  statement {
    sid       = "SecretAccess"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.rds_secret_arn]
  }

  statement {
    sid       = "S3Write"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket}/${var.s3_prefix}*"]
  }
}

resource "aws_iam_role_policy" "task" {
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task.json
}

###############################################
# ECS クラスターとタスク定義
###############################################
resource "aws_ecs_cluster" "this" {
  name = "db-dump"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "db-dump"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "dump"
      image     = local.image
      essential = true
      command   = ["/bin/sh", "-c", local.dump_command]

      environment = [
        { name = "S3_BUCKET", value = var.s3_bucket },
        { name = "S3_PREFIX", value = var.s3_prefix }
      ]

      secrets = [
        { name = "DB_USERNAME", valueFrom = "${var.rds_secret_arn}:username::" },
        { name = "DB_PASSWORD", valueFrom = "${var.rds_secret_arn}:password::" },
        { name = "DB_HOST", valueFrom = "${var.rds_secret_arn}:host::" },
        { name = "DB_PORT", valueFrom = "${var.rds_secret_arn}:port::" },
        { name = "DB_NAME", valueFrom = "${var.rds_secret_arn}:dbname::" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "db-dump"
        }
      }
    }
  ])
}

###############################################
# EventBridge: スケジュール実行
###############################################
resource "aws_cloudwatch_event_rule" "this" {
  name                = "db-dump-schedule"
  description         = "Schedule DB dump task"
  schedule_expression = var.schedule_expression
}

# EventBridge が RunTask を実行する際に利用するロール
resource "aws_iam_role" "eventbridge" {
  name_prefix = "db-dump-ev-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

data "aws_iam_policy_document" "eventbridge" {
  statement {
    actions   = ["ecs:RunTask"]
    resources = [aws_ecs_task_definition.this.arn]
  }
  statement {
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.execution.arn, aws_iam_role.task.arn]
  }
}

resource "aws_iam_role_policy" "eventbridge" {
  role   = aws_iam_role.eventbridge.id
  policy = data.aws_iam_policy_document.eventbridge.json
}

resource "aws_cloudwatch_event_target" "this" {
  rule      = aws_cloudwatch_event_rule.this.name
  target_id = "db-dump"
  arn       = aws_ecs_cluster.this.arn
  role_arn  = aws_iam_role.eventbridge.arn

  ecs_target {
    launch_type         = "FARGATE"
    platform_version    = "LATEST"
    task_definition_arn = aws_ecs_task_definition.this.arn
    network_configuration {
      subnets          = var.subnet_ids
      security_groups  = [var.security_group_id]
      assign_public_ip = false
    }
  }
}

###############################################
# その他
###############################################
# 現時点では追加の出力用リソースはありません。
###############################################
