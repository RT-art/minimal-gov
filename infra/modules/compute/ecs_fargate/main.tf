#############################################
# Security Group 
#############################################
module "ecs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.app_name}-${var.env}-ecssg"
  description = "Security group for ECS service"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = var.container_port
      to_port                  = var.container_port
      protocol                 = "tcp"
      source_security_group_id = var.alb_security_group_id
      description              = "Allow ALB to reach ECS service"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all outbound"
    }
  ]

  tags = merge(
    {
      Name = "${var.app_name}-${var.env}-ecssg"
    },
    var.tags
  )
}
#############################################
# CloudWatch Logs
#############################################
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 30
  tags = merge(
    {
      Name = "${var.app_name}-${var.env}-ecssg"
    },
    var.tags
  )
}

#############################################
# ECS 
#############################################
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 6.4"

  cluster_name = "${var.app_name}-${var.env}-ecs"
  tags = merge(
    {
      Name = "${var.app_name}-${var.env}-ecs"
    },
    var.tags
  )

  services = {
    ("${var.app_name}-${var.env}-ecs-service") = {
      cpu           = var.task_cpu
      memory        = var.task_memory
      desired_count = var.desired_count

      # コンテナ定義
      container_definitions = {
        app = {
          image = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.app_name}:${var.image_tag}"

          portMappings = [
            {
              containerPort = var.container_port
              hostPort      = var.container_port
              protocol      = "tcp"
            }
          ]

          environment = [
            { name = "ENV", value = var.env }
          ]

          # CloudWatch Logs
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = aws_cloudwatch_log_group.ecs.name
              awslogs-region        = var.region
              awslogs-stream-prefix = "ecs"
            }
          }
        }
      }

      # サブネット/SG
      subnet_ids         = var.subnet_ids
      security_group_ids = [module.ecs_sg.security_group_id]

      # ALBターゲットグループ
      load_balancer = {
        service = {
          target_group_arn = var.alb_target_group_arn
          container_name   = "app"
          container_port   = var.container_port
        }
      }

      # ECS Exec の有効化
      enable_execute_command = true
    }
  }
}
