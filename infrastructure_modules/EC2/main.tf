#EC2 Module

# AMI ID の取得 
data "aws_ami" "selected_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }
}

# UserData のレンダリング
locals {
  rendered_user_data = templatefile("${path.module}/${var.user_data_template_path}", {
    # テンプレート内で使用する変数を渡す
    docker_image_name = var.docker_image_name
  })
}


module "ec2_instance" {
  source = "../../resource_modules/compute/ec2"

  # --- 基本設定 ---
  name          = var.instance_name
  instance_type = var.instance_type
  ami           = data.aws_ami.selected_ami.id
  key_name      = var.instance_key_name

  # --- ネットワーク設定 ---
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id] # リスト形式で渡す
  associate_public_ip_address = false                   # EIP を使うため false

  # --- User Data ---
  user_data = local.rendered_user_data # レンダリングした UserData を渡す

  # --- Tags ---
  tags = var.tags
}

# 既存 EIP の取得 (元のコードと同様に data source を使用)
data "aws_eip" "existing_eip" {
  filter {
    name   = "tag:Name"
    values = [var.eip_name_tag_filter]
  }
}

# EIP の関連付け 
resource "aws_eip_association" "eip_assoc" {
  instance_id = module.ec2_instance.id
  allocation_id = data.aws_eip.existing_eip.id
}