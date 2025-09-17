include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/ecs-fargate"
}

inputs = {
  # Metadata
  env      = "dev"
  app_name = "portfolio-app"
  tags = {
    Project     = "minimal-gov"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }

  # Service settings
  service_name         = "portfolio-app"
  container_image      = "123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/portfolio:latest"
  container_port       = 8080
  subnet_ids           = dependency.vpc.outputs.private_subnets
  alb_target_group_arn = dependency.alb.outputs.target_group_arn
  security_groups      = [dependency.rds.outputs.sg_id]
}