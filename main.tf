module "network" {
  source                   = "./modules/network"
  module_vpc_cidr_block    = var.root_vpc_cidr_block
  module_subnet_cidr_block = var.root_subnet_cidr_block
  module_availability_zone = var.root_availability_zone
}

module "security_group" {
  source = "./modules/security_group"
  module_vpc_id = module.network.vpc_id
}

module "ec2_instance" {
  source                   = "./modules/ec2_instance"
  module_instance_type     = var.root_instance_type
  module_ami_name_filter   = var.root_ami_name_filter
  module_instance_key_name = var.root_instance_key_name
  module_docker_image_name = var.root_docker_image_name
  module_subnet_id         = module.network.subnet_id
  module_security_group_id = module.security_group.security_group_id
}
