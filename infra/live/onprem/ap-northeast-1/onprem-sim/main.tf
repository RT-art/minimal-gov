module "onprem_sim" {
  source = "../../../../modules/onprem-sim"

  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  az                 = var.az
  instance_type      = var.instance_type
  ami_id             = var.ami_id
  name_prefix        = var.name_prefix
  tags               = var.tags
}
