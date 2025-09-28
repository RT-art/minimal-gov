locals {
  ecr_repository_name = "${local.name_prefix}-app"
  container_image_tag = "latest"
}

resource "aws_ecr_repository" "app" {
  name = local.ecr_repository_name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-ecr"
  })
}

output "ecr_repository_name" {
  description = "Name of the created ECR repository"
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_url" {
  description = "URL to push images to the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

data "aws_region" "current" {}

locals {
  ecs_container_port = 8080
  ecs_task_family    = "${local.name_prefix}-task"
  ecs_environment    = try(local.tags["Environment"], "dev")
}

resource "aws_security_group" "ecs" {
  name        = "${local.name_prefix}-ecs-sg"
  description = "Allow inbound HTTP for ECS tasks"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP"
    from_port   = local.ecs_container_port
    to_port     = local.ecs_container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-ecs-sg"
  })
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.name_prefix}"
  retention_in_days = 7

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-ecs-logs"
  })
}

resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-cluster"

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-cluster"
  })
}

data "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"
}

resource "aws_ecs_task_definition" "app" {
  family                   = local.ecs_task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${aws_ecr_repository.app.repository_url}:${local.container_image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = local.ecs_container_port
          hostPort      = local.ecs_container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = [
        { name = "ENV", value = local.ecs_environment },
        { name = "PORT", value = tostring(local.ecs_container_port) }
      ]
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "${local.name_prefix}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.this["ecs"].id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_ecs_task_definition.app
  ]
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}
