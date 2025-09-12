data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "minimal-gov-dev-backend-tfstate-ap-northeast-1-351277498040"
    key    = "state/vpc/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "waf" {
  backend = "s3"
  config = {
    bucket = "minimal-gov-dev-backend-tfstate-ap-northeast-1-351277498040"
    key    = "state/waf/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

module "api" {
  source            = "../../../../modules/ecs-alb-service"
  service_name      = "api"
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids        = flatten(values(data.terraform_remote_state.vpc.outputs.private_subnet_ids_by_az))
  container_image   = var.container_image
  container_port    = var.container_port
  desired_count     = var.desired_count
  task_cpu          = var.task_cpu
  task_memory       = var.task_memory
  allowed_cidrs     = var.allowed_cidrs
  health_check_path = var.health_check_path
  waf_acl_arn       = data.terraform_remote_state.waf.outputs.web_acl_arn
  tags              = var.tags
}
