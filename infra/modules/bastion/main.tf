###############################################
# Minimal Gov: Bastion module
#
# このモジュールは、プライベートサブネット内に SSM/EIC 接続が可能な
# 踏み台用 EC2 インスタンスを 1 台作成します。
# - Amazon Linux 2023 を既定 AMI として自動取得（指定も可能）
# - SSM 管理用 IAM ロール + 任意の追加ポリシーアタッチ
# - ルートボリュームの暗号化、IMDSv2 強制などのセキュリティ既定値
#
# 入力はシンプルさを優先し、既存のサブネット/セキュリティグループ
# を指定するだけで利用できます。
###############################################

###############################################
# Locals
###############################################
locals {
  # name_prefix は未指定なら "bastion" を利用
  name_prefix = var.name_prefix != null && var.name_prefix != "" ? var.name_prefix : "bastion"

  # 使用する AMI ID。指定がない場合は Amazon Linux 2023 の最新を自動取得
  ami_id = var.ami_id != null && var.ami_id != "" ? var.ami_id : data.aws_ami.al2023[0].id

  # IAM ポリシー。SSM 管理ポリシーを既定で付与し、追加分を連結
  iam_policy_arns = concat([
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ], var.iam_policy_arns)
}

###############################################
# Data Sources
# - Amazon Linux 2023 の最新 AMI を検索（必要時のみ）
###############################################
data "aws_ami" "al2023" {
  count       = var.ami_id == null || var.ami_id == "" ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

###############################################
# IAM Role & Instance Profile
# - EC2 から SSM や追加ポリシーを利用するためのロール
###############################################
resource "aws_iam_role" "this" {
  name = "${local.name_prefix}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge({
    Name = "${local.name_prefix}-role"
  }, var.tags)
}

resource "aws_iam_instance_profile" "this" {
  name = "${local.name_prefix}-profile"
  role = aws_iam_role.this.name
}

# 指定された各ポリシーをロールへアタッチ
resource "aws_iam_role_policy_attachment" "this" {
  for_each   = toset(local.iam_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

###############################################
# EC2 Instance (Bastion)
# - プライベートサブネットに配置、SSM 経由で操作
# - ルートボリューム暗号化、IMDSv2 強制などを有効化
###############################################
resource "aws_instance" "this" {
  ami                    = local.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.this.name

  # パブリック IP は割り当てず、踏み台としての閉域性を維持
  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # IMDSv2 を強制
  }

  # ルートボリュームは既定 KMS で暗号化
  root_block_device {
    encrypted = true
  }

  tags = merge({
    Name = "${local.name_prefix}-ec2"
  }, var.tags)
}

