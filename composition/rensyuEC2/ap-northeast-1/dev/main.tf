# composition/my-app/ap-northeast-1/dev/main.tf

########################################
# Network Infrastructure
########################################
module "network" {
  source = "../../../../infrastructure_modules/vpc" # 作成したNetwork用Infraモジュールのパス

  vpc_cidr_block    = var.comp_vpc_cidr_block
  subnet_cidr_block = var.comp_subnet_cidr_block
  availability_zone = var.comp_availability_zone
  tags              = local.common_tags
}

########################################
# Compute Infrastructure
########################################
module "compute" {
  source = "../../../../infrastructure_modules/EC2" # EC2用Infraモジュールのパス

  # SG
  vpc_id              = module.network.vpc_id
  ingress_cidr_blocks = var.comp_ingress_cidr_blocks
  tags                = local.common_tags

  # EC2
  instance_name          = var.comp_instance_name
  instance_type          = var.comp_instance_type
  ami_ssm_parameter_name = var.comp_ami_ssm_parameter_name
  instance_key_name      = var.comp_instance_key_name
  subnet_id              = module.network.subnet_id
  eip_name_tag_filter    = var.comp_eip_name_tag_filter
  docker_image_name      = var.comp_docker_image_name
}