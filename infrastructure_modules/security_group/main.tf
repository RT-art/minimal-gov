# infrastructure_modules/security_group/main.tf

module "sg" {
  # リソースモジュールを参照
  source = "../../resource_modules/compute/security_group"

  # --- 基本設定 ---
  name        = var.sg_name
  description = "Security Group for practice EC2 instance allowing HTTP, HTTPS, SSH ingress and all egress."
  vpc_id      = var.vpc_id

  # --- ルール設定 ---
  # Ingress Rules: HTTP (80), HTTPS (443), SSH (22) from specified CIDR blocks
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "ssh-tcp"]
  ingress_cidr_blocks = var.ingress_cidr_blocks
  # 他の Ingress オプション (source_security_group_id, self など) はデフォルトの []

  # Egress Rules: Allow all outbound traffic
  egress_rules = ["all-all"]
  # egress_cidr_blocks はデフォルトで ["0.0.0.0/0"] なので指定不要
  # egress_ipv6_cidr_blocks もデフォルトで ["::/0"]

  # --- タグ ---
  tags = var.tags # 共通タグを受け取る (Name タグはモジュール内で自動的に付与される)

  # --- その他 ---
  # use_name_prefix = true # デフォルトtrue (Nameタグが更新可能)
}