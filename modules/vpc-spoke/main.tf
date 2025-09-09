###############################################
# Minimal Gov: VPC Spoke module
#
# このモジュールは、ワークロード用の「プライベート専用 VPC」を作成します。
# - VPC（DNS サポート/ホストネーム有効）
# - プライベートサブネット（指定 AZ × 指定個数）
# - ルートテーブル（シンプルに「サブネットごとに 1 つ」作成し関連付け）
#
# ここでは NATGW/IGW/TGW などの外部接続は作成しません。
# ルーティングはデフォルト（local のみ）とし、上位モジュールで必要に応じて
# TGW アタッチやルート追加を行う方針です。
#
# 設計指針：
# - ロジックはできるだけ単純化（count は最小限の用途に限定）
# - 変数化を徹底し、読みやすい命名とコメント
# - セキュリティ既定値：インターネット未接続、public IP 自動割当は無効
#
###############################################

###############################################
# Locals
# - name_prefix は任意。タグやリソースの Name に利用します。
###############################################
locals {
  name_prefix = var.name_prefix != null && var.name_prefix != "" ? var.name_prefix : "spoke"

  # 総サブネット数（AZ 数 × AZ あたりのプライベートサブネット個数）
  total_private_subnets = length(var.azs) * var.private_subnet_count_per_az
}

###############################################
# VPC（プライベート専用）
# - DNS サポート/ホストネームは有効化（多くの AWS サービスで必須）
# - IGW/NATGW はここでは作成しない
###############################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "${local.name_prefix}-vpc"
    },
    var.tags,
  )
}

###############################################
# プライベートサブネット
# - 各サブネットは public IP 自動割当を無効化
# - CIDR は `cidrsubnet` を用いて VPC CIDR から均等分割
# - AZ は与えられた順序で循環的に割当
###############################################
resource "aws_subnet" "private" {
  count                   = local.total_private_subnets
  vpc_id                  = aws_vpc.this.id

  # 例）azs = [a, c], per_az = 3 のとき、
  # index:0..5 に対して 0..2 は a、3..5 は c となるように割当
  availability_zone       = element(var.azs, floor(count.index / var.private_subnet_count_per_az))

  # 各サブネットの CIDR を連番で作成
  # newbits は variables.tf の説明参照
  cidr_block              = cidrsubnet(var.vpc_cidr, var.subnet_newbits, count.index)

  # セキュリティ既定値：プライベート用のため public IP は自動付与しない
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = format(
        "%s-private-%s-%02d",
        local.name_prefix,
        element(var.azs, floor(count.index / var.private_subnet_count_per_az)),
        count.index % var.private_subnet_count_per_az,
      )
    },
    var.tags,
  )
}

###############################################
# ルートテーブル（サブネットごとに 1 つ）
# - デフォルトの local ルートのみ（NAT/TGW/VPCE 等は上位で必要に応じて追加）
# - シンプルさと明快さを優先し、各サブネット専用の RT を作成
###############################################
resource "aws_route_table" "private" {
  count  = local.total_private_subnets
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = format(
        "%s-rt-private-%s-%02d",
        local.name_prefix,
        element(var.azs, floor(count.index / var.private_subnet_count_per_az)),
        count.index % var.private_subnet_count_per_az,
      )
    },
    var.tags,
  )
}

###############################################
# ルートテーブル関連付け（サブネット＝RT の 1:1）
###############################################
resource "aws_route_table_association" "private" {
  count          = local.total_private_subnets
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

