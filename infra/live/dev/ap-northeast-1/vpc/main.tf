module "dev_vpc" {
  source                      = "../../../../modules/vpc-spoke"
  vpc_name                    = "dev"
  vpc_cidr                    = var.vpc_cidr
  azs                         = var.azs
  private_subnet_count_per_az = var.private_subnet_count_per_az
  subnet_newbits              = var.subnet_newbits
  tags                        = var.tags
}
