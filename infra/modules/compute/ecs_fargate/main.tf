locals {
  resource_tags = merge({
    Application = var.app_name
    Environment = var.env
  }, var.tags)
}

module "ecs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.service_name}-ecs-sg"
  description = "Security group for ECS service"
  vpc_id      = data.aws_vpc.selected.id

  ingress_with_cidr_blocks = var.alb_security_group_id == null ? [
    {
      from_port   = var.container_port
      to_port     = var.container_port
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    }
  ] : []

  ingress_with_source_security_group_id = var.alb_security_group_id == null ? [] : [
    {
      from_port                = var.container_port
      to_port                  = var.container_port
      protocol                 = "tcp"
      source_security_group_id = var.alb_security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = local.resource_tags
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 30

  tags = local.resource_tags
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.0"

  cluster_name = "${var.service_name}-cluster"
  tags         = local.resource_tags

  services = {
    (var.service_name) = {
      cpu    = 256
      memory = 512

      desired_count = var.desired_count

      container_definitions = {
        app = {
          image = var.container_image
          port_mappings = [
            {
              containerPort = var.container_port
              hostPort      = var.container_port
              protocol      = "tcp"
            }
          ]

          environment = [
            {
              name  = "ENV"
              value = var.env
            }
          ]

          log_configuration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = aws_cloudwatch_log_group.ecs.name
              awslogs-region        = var.region
              awslogs-stream-prefix = "ecs"
            }
          }
        }
      }

      subnet_ids         = var.subnet_ids
      security_group_ids = concat([module.ecs_sg.security_group_id], var.security_groups)

      target_group_arn = var.alb_target_group_arn

      enable_execute_command = true
    }
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

// Removed aws_region data source; using var.region instead to avoid deprecation warnings
