# VPC Module
# 1つのAZにPublic Subnetを作成し、IGWをアタッチする構成
# Public Subnet用にルートテーブルを作成し、IGWへのルートを設定する

module "vpc" {
  source = "../../resource_modules/network"# 作成したNetwork用Infraモジュールのパス

  # --- VPC ---
  name = var.vpc_name
  cidr = var.vpc_cidr_block

  # --- Subnets ---
  # AZとCIDRのみ指定。Public Subnet を1つだけ作成
  azs             = [var.availability_zone]
  public_subnets  = [var.subnet_cidr_block]
  private_subnets = [] # Private Subnet は後日作成
  database_subnets= [] # Database Subnet は後日作成

  # --- Internet Gateway & Routing ---
  create_igw = true  # IGW を作成し VPC にアタッチ (Default: true)
  # enable_nat_gateway    = false # NAT Gateway は後日作成 (Default: false if private_subnets is empty)
  # single_nat_gateway    = false # NAT Gateway は後日作成 (Default: false)

  # --- DNS ---
  enable_dns_support   = true  
  enable_dns_hostnames = true 

  # --- Public Subnet Specific ---
  map_public_ip_on_launch = false # EIPを使用するため、false (Default: true)

  # --- Tags ---
  tags = var.tags
  vpc_tags = merge(var.tags, { 
    Name = var.vpc_name
  })
  public_subnet_tags = merge(var.tags, {
    Name = "subnet-practice-terraform" 
  })
 igw_tags = merge(var.tags, {         
      Name = "internet-gateway-practice-terraform"
  }
  ) 
}