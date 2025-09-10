###############################################
# Minimal Gov: ECS ALB Service module
#
# このモジュールは、内向け Application Load Balancer と
# AWS Fargate ベースの ECS サービスを最小構成で作成します。
# - ALB は指定 CIDR からのみアクセスを許可
# - CloudWatch Logs、IAM ロール、Secrets Manager 連携など
#   セキュリティ既定値を有効化
# - 任意で WAF ACL を ALB に関連付け可能
###############################################

###############################################
# Data Sources
# - 利用リージョンを取得（CloudWatch Logs で使用）
###############################################
data "aws_region" "current" {}

###############################################
# Locals
# - コンテナ定義を生成
###############################################
locals {
  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = var.container_image
      essential = true

      portMappings = [{
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }

      secrets = [for k, v in var.secrets : {
        name      = k
        valueFrom = v
      }]
    }
  ])
}

###############################################
# Security Groups
# - ALB 用: 指定 CIDR からのみ HTTP を許可
# - ECS タスク用: ALB からの通信を許可
###############################################
resource "aws_security_group" "alb" {
  name   = "${var.service_name}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Allowed from specific CIDRs"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.service_name}-alb-sg"
  }, var.tags)
}

resource "aws_security_group" "task" {
  name   = "${var.service_name}-task-sg"
  vpc_id = var.vpc_id

  # タスクからのアウトバウンドは全許可（例: 外部 API など）
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.service_name}-task-sg"
  }, var.tags)
}

###############################################
# CloudWatch Log Group
# - アプリログを収集（削除保護は Terraform 管理外のため無効）
###############################################
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 30
  kms_key_id        = null # 既定のサービス管理キーで暗号化
  tags              = var.tags
}

###############################################
# IAM Role for ECS Tasks
# - CloudWatch Logs 送信や Secrets 取得に必要な権限
###############################################
resource "aws_iam_role" "task_execution" {
  name = "${var.service_name}-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge({
    Name = "${var.service_name}-exec-role"
  }, var.tags)
}

# 既定の ECS タスク実行ポリシーを付与（ECR/Pull Logs 等）
resource "aws_iam_role_policy_attachment" "exec" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

###############################################
# ECS Cluster
###############################################
resource "aws_ecs_cluster" "this" {
  name = "${var.service_name}-cluster"
  tags = var.tags
}

###############################################
# ECS Task Definition
###############################################
resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task_execution.arn
  container_definitions    = local.container_definitions

  tags = var.tags
}

###############################################
# Application Load Balancer + Target Group + Listener
###############################################
resource "aws_lb" "this" {
  name                       = "${var.service_name}-alb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.subnet_ids
  enable_deletion_protection = true

  tags = merge({
    Name = "${var.service_name}-alb"
  }, var.tags)
}

resource "aws_lb_target_group" "this" {
  name        = "${var.service_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = var.tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

###############################################
# Optional: WAFv2 Web ACL Association
###############################################
resource "aws_wafv2_web_acl_association" "this" {
  count = var.waf_acl_arn != null && var.waf_acl_arn != "" ? 1 : 0

  resource_arn = aws_lb.this.arn
  web_acl_arn  = var.waf_acl_arn
}

###############################################
# ECS Service
###############################################
resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.task.id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = var.tags
}

