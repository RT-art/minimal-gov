#Security Group

module "sg" {
  source              = "../../resource_modules/compute/security_group"
  name                = var.sg_name
  description         = "Security Group for practice EC2 instance allowing HTTP, HTTPS, SSH ingress and all egress."
  vpc_id              = var.vpc_id
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "ssh-tcp"]
  ingress_cidr_blocks = var.ingress_cidr_blocks
  egress_rules        = ["all-all"]
  tags                = var.tags
}

locals {
  rendered_user_data = templatefile("${path.module}/${var.user_data_template_path}", {

    docker_image_name = var.docker_image_name
  })
}

#EC2
module "ec2_instance" {
  source                      = "../../resource_modules/compute/ec2_instance"
  name                        = var.instance_name
  instance_type               = var.instance_type
  key_name                    = var.instance_key_name
  ami_ssm_parameter           = var.ami_ssm_parameter_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [module.sg.security_group_id]
  associate_public_ip_address = false # EIP を使うため false
  user_data                   = local.rendered_user_data
  tags                        = var.tags
}

data "aws_eip" "existing_eip" {
  filter {
    name   = "tag:Name"
    values = [var.eip_name_tag_filter]
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = module.ec2_instance.id
  allocation_id = data.aws_eip.existing_eip.id
}