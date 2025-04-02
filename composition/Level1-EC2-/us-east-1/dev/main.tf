# composition/my-app/ap-northeast-1/dev/main.tf

########################################
# Network Infrastructure
########################################
module "network" {
  source = "../../infrastructure_modules/network"

  vpc_cidr_block    = var.comp_vpc_cidr_block
  subnet_cidr_block = var.comp_subnet_cidr_block
  availability_zone = var.comp_availability_zone
  tags              = local.common_tags
}

# ########################################
# # Security Group Infrastructure
# ########################################
module "security_group" {
  source = "../../infrastructure_modules/security_group" # 作成したSG用Infraモジュールのパス

  vpc_id              = module.network.vpc_id # NetworkモジュールからVPC IDを取得
  ingress_cidr_blocks = var.comp_ingress_cidr_blocks
  tags                = local.common_tags
  # sg_name = "custom-sg-name" # 必要なら Name タグを上書き
}

########################################
# Compute Infrastructure
########################################
module "compute" {
  source = "../../infrastructure_modules/compute"

  # --- 基本設定 ---
  instance_name     = var.comp_instance_name
  instance_type     = var.comp_instance_type
  ami_name_filter   = var.comp_ami_name_filter
  instance_key_name = var.comp_instance_key_name

  # --- ネットワーク設定 (Network & SecurityGroup モジュールの出力と変数を参照) ---
  subnet_id         = module.network.subnet_id
  security_group_id = module.security_group.security_group_id # ★ SGモジュールの出力を使うように変更 ★

  # --- EIP設定 ---
  eip_name_tag_filter = var.comp_eip_name_tag_filter

  # --- UserData ---
  docker_image_name = var.comp_docker_image_name

  # --- タグ ---
  tags = local.common_tags
}