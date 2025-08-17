data "aws_caller_identity" "current" {}

module "ec2" {
  source       = "../../../../modules/workloads/ec2-minimal"
  env          = var.env
  app_name     = var.app_name
  region       = var.region
  instance_type = var.instance_type
  tags         = {}
}
