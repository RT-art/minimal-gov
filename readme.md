# Minimal Gov Terraform Architecture Guide

## 1. 仕様

### 1.1 ユーザ（市役所職員）
- site-to-site VPN → Network アカウントの TGW → Prod / Dev アカウントの ECS アプリケーションへ ALB 経由でアクセス

### 1.2 運用保守
- site-to-site VPN → Network アカウント内 EC2 → TGW アタッチメント + ポートフォワーディング → Prod / Dev 環境へ到達

### 1.3 運用保守拠点
- オンプレと AWS で IP 重複を想定。SSM 接続 + ポートフォワーディングで ECS / RDS へ接続
- バックアップサーバを設置
- Prod RDS → S3（論理ダンプ）→ Transfer Family → バックアップサーバでリストア
- AWS サービスとの通信はすべて VPC エンドポイント経由
- Organization を用いてセキュリティアカウントにセキュリティリソースを集約
- Route53 はプライベートホストゾーンを使用し、DNS リゾルバ + RAM で全 VPC から名前解決可能

## 2. アーキテクチャ設計

### 2.1 図
![アーキテクチャ図](./image/アーキテクチャ図.png)  
![Organization図](./image/Organization.png)

### 2.2 全体像
- **アカウント構成**: Security / Network / Prod+Dev の 3 アカウント
- **Network VPC**: 踏み台、TGW Attach×2、Resolver×2、SSM/EIC、必要最小限の VPCE（ssm 系 + logs/kms）
- **TGW**: VGW・Network・Prod・Dev の 4 アタッチメント。ルートテーブルは 3 枚（VGW 用 / Network→Spoke 用 / Spoke→Network 用）
- **DNS**: Prod と Dev に PHZ を作成し RAM 共有。Resolver In/Out でオンプレと疎通
- **ALB（Internal）+ ECS**: ユーザ拠点 CIDR で ALB を制限、WAF 有効
- **RDS**: 論理ダンプを ECS タスク or Systems Manager Run Command で取得 → S3
- **Transfer Family（VPC Hosted）**: オンプレのバックアップサーバに転送
- **ログ**: VPC / TGW / ALB / WAF / Trail を Security アカウント S3（KMS）へ集約

## 3. 各アカウント設計

### 3.1 ネットワークアカウント

#### VPC
- CIDR: `192.168.0.0/16`（インターネット未接続、IGW/NATGW なし）
- AZ: `ap-northeast-1a` / `1c`

#### サブネット
- bastion-a: `192.168.10.0/24`（EC2 踏み台、VPC エンドポイント）
- bastion-c: `192.168.11.0/24`
- tgw-attach-a: `192.168.50.0/28`
- tgw-attach-c: `192.168.50.16/28`
- resolver-in-a: `192.168.60.0/28`
- resolver-in-c: `192.168.60.16/28`
- resolver-out-a: `192.168.61.0/28`
- resolver-out-c: `192.168.61.16/28`
- endpoint-a: `192.168.20.0/28`
- endpoint-c: `192.168.21.0/28`

#### ルートテーブル
- bastion-a,c
- `192.168.0.0/16` → local
- Prod/Dev: `10.0.0.0/16` → TGW
- tgw-attach, resolver → local

#### Transit Gateway
- アタッチメント 4 つ
- att-user-vpn（ユーザ拠点 Site-to-Site VPN）
- att-vgw（Ops/DC 側 VGW アタッチ）
- att-network-vpc（ネットワーク VPC）
- att-dev（Dev VPC）
- ルートテーブル
- rt-user：ユーザ向け（Prod/Dev のみ）
- rt-spoke→network：Prod/Dev から Network への復路
- rt-network→spoke：踏み台から Spoke への経路

#### Site-to-Site VPN
- ユーザ拠点 → TGW（att-user-vpn）
- Ops/DC → VGW（Network VPC）

#### 踏み台 EC2
- 配置: bastion-a,c
- OS: AL2023 / t3.small
- IAM: AmazonSSMManagedInstanceCore + S3/CloudWatchLogs
- 接続: SSM Port Forwarding

#### VPC エンドポイント
- ssm / ssmmessages / ec2messages / logs / kms / EC2 instance connect

#### DNS
- Inbound / Outbound Endpoints
- onprem.example.local → Ops/DC DNS
- AWS 側ドメイン → PHZ 共有

#### セキュリティ
- ログ集約: Security アカウントの S3（KMS）
- 収集対象: Flow Logs / TGW Logs / ALB / WAF / CloudTrail

#### バックアップ経路
- RDS → S3 → Transfer Family → DC バックアップサーバ

#### リソース作成順序
1. TGW 作成（3 ルートテーブル）
2. Network VPC（Attach / Resolver）
3. VPCE・踏み台 EC2
4. VPN 設定
5. Prod / Dev アタッチ

## 4. EC2 インスタンス

| 名称 | AMI | サイズ | 要件 |
| --- | --- | --- | --- |
| user-cgw | strangswanwo | t3.small | EIP 付与, Src/Dst Check 無効, UDP 500/4500 |
| ops-cgw | strangswanwo | t3.small | 同上 |
| user-client | AL2023 | t3.micro | 疑似ユーザ端末 |
| backup-server | AL2023 | t3.small | バックアップ取得用 |

### セキュリティグループ
- CGW: UDP 500/4500, ICMP
- client / backup: Outbound All, Inbound SSH

## 5. VPN (AWS 側)
- ユーザ拠点 → TGW  
- 宛先: `10.0.0.0/16`, `10.2.0.0/16`
- 運用保守 → VGW  
- 宛先: `192.168.0.0/16`

## 6. ルーティング
- ユーザ拠点 VPC  
- `10.0.0.0/16`, `10.2.0.0/16` → user-cgw
- 運用保守 VPC  
- `192.168.0.0/16` → ops-cgw

## 7. strongSwan 設定

### OS 設定
```bash
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv4.conf.all.accept_redirects=0
sudo sysctl -w net.ipv4.conf.all.send_redirects=0
```

### ユーザ拠点 `/etc/ipsec.conf`
```conf
conn tgw-tun1
keyexchange=ikev2
type=tunnel
authby=psk
ike=aes256-sha256-modp2048!
esp=aes256-sha256!
left=%defaultroute
leftid=<LEFT_EIP>
leftsubnet=172.0.0.0/16
right=<TUN1_REMOTE>
rightsubnet=10.0.0.0/16,10.2.0.0/16
dpdaction=restart
auto=start

conn tgw-tun2
also=tgw-tun1
right=<TUN2_REMOTE>
```

### 運用保守 `/etc/ipsec.conf`
```conf
conn vgw-tun1
keyexchange=ikev2
type=tunnel
authby=psk
ike=aes256-sha256-modp2048!
esp=aes256-sha256!
left=%defaultroute
leftid=<LEFT_EIP>
leftsubnet=10.0.0.0/16
right=<TUN1_REMOTE>
rightsubnet=192.168.0.0/16
dpdaction=restart
auto=start

conn vgw-tun2
also=vgw-tun1
right=<TUN2_REMOTE>
```

### secrets
```conf
<LEFT_EIP> <TUN1_REMOTE> : PSK "<PSK>"
<LEFT_EIP> <TUN2_REMOTE> : PSK "<PSK>"
```

## 8. バックアップ経路（CIDR 重複あり）
`backup-server → (VPN to VGW) → Network 踏み台 EC2 → (TGW) → Transfer Family`

### SSH 設定例
```sshconfig
Host bastion
HostName <Network_VPC_Bastion_PrivateIP>
User ec2-user
IdentityFile ~/.ssh/bastion.pem

Host tf
HostName <Transfer_Family_PrivateIP>
User sftp-user
```

## 9. Module 設計

本レポジトリを継続的かつ安全に横展開するため、再利用可能な Terraform module を以下の方針で整備する。

- 命名: `modules/<module-name>`
- 共通入力: `var.name_prefix`（任意）, `var.tags`（map(string)）
- 出力は「上位からの依存に必要な最小限」に限定
- セキュリティ既定値（暗号化/公開ブロック/検証など）は module 内でデフォルト有効
- 可能なものは疎結合（ハブ/スポーク/接続を分離）

### 9.1 VPC Spoke（Workloads 用 VPC）
- 役割: Prod/Dev 等のワークロード VPC を作成（プライベートサブネットのみ）
- 提供物: VPC、本番・開発用のプライベートサブネット（AZ 別に複数）、ルートテーブル
- 依存: なし（TGW/VPCE は別 module）
- 想定配置: `modules/vpc-spoke`
- 入力例:
- `vpc_cidr` string（例: 10.0.0.0/16）
- `azs` list(string)（例: ["ap-northeast-1a", "ap-northeast-1c"]）
- `private_subnet_count_per_az` number（例: 3）
- `subnet_newbits` number（例: 8）
- `name_prefix` string, `tags` map(string)
- 出力例:
- `vpc_id` string
- `private_subnet_ids_by_az` map(string => list(string))
- `route_table_ids` list(string)
- 使用例:
```hcl
module "dev_vpc" {
source                       = "../modules/vpc-spoke"
name_prefix                  = "dev"
vpc_cidr                     = "10.0.0.0/16"
azs                          = ["ap-northeast-1a", "ap-northeast-1c"]
private_subnet_count_per_az  = 3
subnet_newbits               = 8
tags = {
    Project = "minimal-gov"
    Env     = "dev"
}
}
```

### 9.2 TGW Hub（ハブアカウント用）
- 役割: Transit Gateway 本体＋ルートテーブル（3 枚）＋RAM 共有の作成
- 提供物: `tgw_id`、`rt_user_id`、`rt_spoke_to_network_id`、`rt_network_to_spoke_id`、`ram_share_arn`
- 依存: なし（アタッチは別 module）
- 想定配置: `modules/tgw-hub`
- 入力例:
- `tgw_name` string（例: tgw-hub）
- `ram_share_name` string（例: tgw-hub-share）
- `tags` map(string)
- 出力例:
- `tgw_id`, `rt_user_id`, `rt_spoke_to_network_id`, `rt_network_to_spoke_id`, `ram_share_arn`
- 使用例:
```hcl
module "tgw_hub" {
source         = "../modules/tgw-hub"
tgw_name       = "tgw-hub"
ram_share_name = "tgw-hub-share"
tags = {
    Project = "minimal-gov"
    Account = "network"
}
}
```

### 9.3 TGW VPC Attachment（スポーク接続）
- 役割: 共有済み TGW への VPC アタッチメントと RT Association/Propagation
- 提供物: アタッチメント ID、関連 Association/Propagation の完了状態
- 依存: TGW Hub（`tgw_id` と RT IDs）、VPC Spoke（`vpc_id`、`subnet_ids`）
- 想定配置: `modules/tgw-vpc-attachment`
- 入力例:
- `tgw_id` string
- `vpc_id` string
- `subnet_ids` list(string)
- `associate_route_table_id` string（例: `rt_user_id`）
- `propagate_route_table_ids` list(string)（例: [`rt_spoke_to_network_id`]）
- `name_prefix` string, `tags` map(string)
- 出力例:
- `attachment_id` string
- 使用例:
```hcl
module "dev_tgw_attach" {
source                     = "../modules/tgw-vpc-attachment"
tgw_id                     = data.aws_ec2_transit_gateway.hub.id
vpc_id                     = module.dev_vpc.vpc_id
subnet_ids                 = flatten(values(module.dev_vpc.private_subnet_ids_by_az))
associate_route_table_id   = module.tgw_hub.rt_user_id
propagate_route_table_ids  = [module.tgw_hub.rt_spoke_to_network_id]
name_prefix                = "tgw-dev-attach"
}
```

### 9.4 VPC Endpoints Baseline（SSM/Logs/KMS/EIC）
- 役割: 必須の Interface/Gateway VPC エンドポイント群を一括作成
- 提供物: エンドポイント IDs と DNS 名等
- 依存: VPC/サブネット/SG
- 想定配置: `modules/vpc-endpoints-baseline`
- 入力例:
- `vpc_id` string
- `subnet_ids` list(string)
- `security_group_id` string
- `services` list(string)（既定: ssm, ssmmessages, ec2messages, logs, kms, ec2-instance-connect）
- `endpoint_policy_json` string（任意）
- `tags` map(string)
- 出力例:
- `endpoint_ids` map(string => string)

### 9.5 Route53 Resolver Endpoints + Rules
- 役割: Inbound/Outbound エンドポイントとフォワーダールールの作成
- 提供物: inbound/outbound endpoint IDs、rule IDs
- 依存: VPC/サブネット
- 想定配置: `modules/resolver-endpoints`
- 入力例:
- `vpc_id` string
- `inbound_subnet_ids` list(string)
- `outbound_subnet_ids` list(string)
- `forward_rules` list(object({ domain = string, target_ips = list(string) }))
- `tags` map(string)
- 出力例:
- `inbound_endpoint_id`, `outbound_endpoint_id`, `rule_ids`

### 9.6 Security: CloudTrail（Org 集約）
- 役割: 監査ログ集約用の S3 バケット＋Organization Trail の作成
- 依存: なし（S3 の既定セキュリティは module 内で有効）
- 想定配置: `modules/security-cloudtrail`
- 入力例:
- `trail_name` string
- `bucket_name` string（自動命名なら `name_prefix`）
- `use_kms` bool（既定 false）, `kms_key_id` string（任意）
- `enable_logging` bool（既定 true）
- `tags` map(string)
- 出力例:
- `trail_arn`, `bucket_name`

### 9.7 Security: AWS Config（Recorder/Delivery/Aggregator）
- 役割: Config のレコーダ/配信 S3/オーガ集約の一式
- 想定配置: `modules/security-config`
- 入力例:
- `bucket_name` string（または `create_bucket` bool）
- `aggregator_role_name` string（既定値あり）
- `snapshot_delivery_frequency` string（既定: TwentyFour_Hours）
- `tags` map(string)
- 出力例:
- `recorder_name`, `delivery_channel_name`, `aggregator_arn`

### 9.8 Security: GuardDuty（Org 有効化）
- 役割: Detector 作成＋組織メンバー自動有効化
- 想定配置: `modules/security-guardduty`
- 入力例: `auto_enable_members`（既定 ALL）, `tags`
- 出力例: `detector_id`

### 9.9 Security: Security Hub（Org 有効化＋標準購読）
- 役割: Security Hub 有効化、AFSBP 標準購読、Finding Aggregator
- 想定配置: `modules/security-securityhub`
- 入力例: `enable_afsbp` bool, `linking_mode` string（既定 ALL_REGIONS）, `tags`
- 出力例: `finding_aggregator_arn`

### 9.10 SSO Permission Set + Assignment
- 役割: PermissionSet 作成、マネージドポリシー付与、ユーザ/アカウント割当
- 想定配置: `modules/sso-permission-set`
- 入力例:
- `permission_set_name` string（例: AdministratorAccess）
- `managed_policy_arns` list(string)
- `instance_arn` string（または自動検出を有効）
- `assignments` list(object({ account_id = string, principal_type = string, principal_id = string }))
- 出力例: `permission_set_arn`
- 備考: 組織アカウント ID は remote state または入力で渡す

### 9.11 Organization Delegations（委任管理者登録）
- 役割: GuardDuty / Security Hub / CloudTrail の Delegated Admin 登録
- 想定配置: `modules/org-delegations`
- 入力例:
- `security_account_id` string
- `enable_guardduty` bool, `enable_securityhub` bool, `enable_cloudtrail` bool（既定いずれも true）
- 出力例: なし（副作用がメイン）

### 9.12 Site-to-Site VPN（TGW 側）
- 役割: Customer Gateway + VPN Connection（対 TGW）を標準化
- 想定配置: `modules/vpn-tgw`
- 入力例:
- `tgw_id` string, `customer_gateway_ip` string, `asn` number
- `routes` list(string)（宛先 CIDR）
- `tunnel_options` object（暗号／DPD 等, 任意）
- 出力例: `vpn_connection_id`, `cgw_id`

### 9.13 VGW + VPN（Network 側・Ops/DC 連携）
- 役割: VGW 作成、VPC アタッチ、Customer Gateway + VPN（対 VGW）
- 想定配置: `modules/vpn-vgw`
- 入力例: `vpc_id`, `customer_gateway_ip`, `asn`, `routes`
- 出力例: `vgw_id`, `vpn_connection_id`

### 9.14 Bastion（踏み台 EC2, SSM/EIC）
- 役割: プライベートサブネット上に SSM/EIC で接続可能な踏み台 EC2 を作成
- 想定配置: `modules/bastion`
- 入力例: `subnet_id`, `security_group_id`, `instance_type`, `ami_id`（既定 AL2023 自動解決）, `iam_policy_arns`（SSM など）
- 出力例: `instance_id`

### 9.15 On-prem 疑似環境（デモ用途）
- 役割: VPC + パブリックサブネット + IGW + StrongSwan EC2 + EIP を一式で構築
- 想定配置: `modules/onprem-sim`
- 入力例: `vpc_cidr`, `public_subnet_cidr`, `az`, `instance_type`
- 出力例: `vpc_id`, `subnet_id`, `instance_id`, `eip`

### 9.16 既存 module（維持）
- `modules/organizations`: OU/アカウント作成/委任の土台（呼出: `Organization/main.tf`）
- `modules/scp`: ベースライン + 任意 SCP 管理（呼出: `Organization/main.tf`）
- `modules/backend`: セキュアな S3 バケット（Terraform backend 等に流用）

### 9.17 実装順序（推奨）
1. `tgw-hub`（RAM 共有まで）
2. `vpc-spoke`（Dev/Prod）
3. `tgw-vpc-attachment`（Dev/Prod を接続）
4. `vpc-endpoints-baseline` / `resolver-endpoints`
5. Security 系（`security-cloudtrail` → `security-config` → `security-guardduty` → `security-securityhub`）
6. `org-delegations` / `sso-permission-set`
7. `vpn-tgw` / `vpn-vgw` / `bastion` / `onprem-sim`（必要に応じて）


### SFTP 実行例
```bash
sftp -o ProxyJump=bastion tf:/export/xxxx.dmp /data/restore/
```

## 9. 構築手順（最短）
1. ユーザ拠点 / 運用保守 VPC 作成
2. IGW アタッチ + 公開サブネット作成
3. EC2 起動（strangswanwo AMI）、EIP 割当、Src/Dst Check 無効
4. SG 設定（UDP 500/4500）
5. AWS 側 VPN 作成（TGW, VGW）
6. strongSwan 設定投入 & 再起動
7. オンプレ VPC ルート設定
8. DNS 設定（ユーザ拠点は Inbound Resolver）
9. 必要なら backup-server 起動

### 9.18 Workload: ECS + ALB（Fargate ワンパッケージ）

`modules/ecs-alb-service`

**役割**: 内部 ALB + TargetGroup + Listener + SG、ECS Cluster、TaskDef、Fargate Service、CloudWatch Logs、（任意）WAF 連携を一括作成

**前提**: Workload VPC（プライベートサブネット）、Route53/VPCE は別モジュール

**入力**

- `service_name` (string) — 例: "app"
- `vpc_id` (string)
- `subnet_ids` (list(string)) — プライベート
- `container_image` (string) — 例: "123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/app:latest"
- `container_port` (number) — 例: `8080`
- `desired_count` (number) — 例: `2`
- `task_cpu` (number) — 例: `512`
- `task_memory` (number) — 例: `1024`
- `allowed_cidrs` (list(string)) — ユーザ拠点 CIDR（ALB の SG に適用）
- `health_check_path` (string) — 例: "/health"
- `env` (map(string)) — 環境変数（平文）
- `secrets` (map(string)) — name => secretsmanager arn
- `waf_acl_arn` (string, optional) — ある場合は ALB にアタッチ

**出力**

- `alb_dns_name`
- `alb_arn`
- `alb_sg_id`
- `listener_arn`
- `cluster_arn`
- `service_arn`
- `task_role_arn`
- `exec_role_arn`

**使用例**

```hcl
module "api" {
  source          = "../modules/ecs-alb-service"
  service_name    = "api"
  vpc_id          = module.dev_vpc.vpc_id
  subnet_ids      = flatten(values(module.dev_vpc.private_subnet_ids_by_az))
  container_image = "${module.ecr.repository_url}:latest"
  container_port  = 8080
  desired_count   = 2
  task_cpu        = 512
  task_memory     = 1024
  allowed_cidrs   = ["172.0.0.0/16"] # ユーザ拠点
  health_check_path = "/health"
  env = { ENV = "dev" }
  secrets = { DB_PASSWORD = module.db.secret_arn }
  waf_acl_arn = module.waf.web_acl_arn
}
```

### 9.19 WAF（WebACL）

`modules/waf-acl`

**役割**: WAFv2 WebACL を作成し、基本ルール + 許可 IPSet（ユーザ拠点 CIDR）を適用。ログ出力（任意）

**入力**

- `name` (string)
- `allow_cidrs` (list(string)) — 許可元
- `enable_logging` (bool) — 既定: `false`
- `log_destination_arn` (string, optional) — Kinesis Firehose など
- `managed_rule_sets` (list(string)) — 既定: ["AWSManagedRulesCommonRuleSet","AWSManagedRulesKnownBadInputsRuleSet"]

**出力**

- `web_acl_arn`

**使用例**

```hcl
module "waf" {
  source         = "../modules/waf-acl"
  name           = "workload"
  allow_cidrs    = ["172.0.0.0/16"]
  enable_logging = false
}
```

### 9.20 RDS（Aurora or 単体）

`modules/rds`

**役割**: DB サブネットグループ、SG、ParameterGroup、RDS（Aurora または 単体）、SecretsManager（自動生成）

**シンプル方針**: 「Aurora Serverless v2」か「db.t3/t4g」などのどちらかを選ぶだけ

**入力**

- `engine` (string) — "aurora-postgresql" / "aurora-mysql" / "postgres" / "mysql"
- `engine_version` (string)
- `subnet_ids` (list(string)) — DB 専用サブネット
- `vpc_id` (string)
- `ingress_sg_ids` (list(string)) — アプリ SG からのみ許可
- サーバレスの場合: `serverless_min_acu`, `serverless_max_acu`
- プロビジョンドの場合: `instance_class`
- `kms_key_id` (string, optional)
- `backup_retention` (number) — 例: `7`

**出力**

- `endpoint`
- `port`
- `sg_id`
- `secret_arn`
- `cluster_arn` (Aurora 時)

**使用例**

```hcl
module "db" {
  source             = "../modules/rds"
  engine             = "aurora-postgresql"
  engine_version     = "15"
  vpc_id             = module.dev_vpc.vpc_id
  subnet_ids         = [for az, ids in module.dev_vpc.private_subnet_ids_by_az : ids[0]]
  ingress_sg_ids     = [module.api.alb_sg_id] # 例: ALB→DB 経路は通常不要。基本は ECS SG を渡す
  serverless_min_acu = 0.5
  serverless_max_acu = 2
  backup_retention   = 7
}
```

### 9.21 Workload 用 VPC エンドポイント

`modules/workload-vpce`

**役割**: ECS に最低限必要な VPCE をまとめて作成（ECR dkr/api、Secrets Manager、CloudWatch Logs、S3 GW）

**入力**

- `vpc_id` (string)
- `subnet_ids` (list(string))
- `security_group_id` (string)
- `services` (list(string), optional) — 省略時は上記デフォルトを作成

**出力**

- `endpoint_ids` (map)

### 9.22 Route53 Private Hosted Zone（サービス公開）

`modules/route53-phz-service`

**役割**: PHZ 作成 + A/ALIAS レコード生成 +（任意）RAM 共有

**入力**

- `zone_name` (string) — 例: "svc.local"
- `vpc_id` (string)
- `records` (list(object({ name = string, type = string, alias_zone_id = string, alias_name = string }))) — ALB Alias を想定
- `share_with_account_ids` (list(string), optional)

**出力**

- `zone_id`

**使用例**

```hcl
module "svc_dns" {
  source    = "../modules/route53-phz-service"
  zone_name = "svc.local"
  vpc_id    = module.dev_vpc.vpc_id
  records = [{
    name          = "api"
    type          = "A"
    alias_zone_id = module.api.alb_zone_id
    alias_name    = module.api.alb_dns_name
  }]
}
```

### 9.23 ECR リポジトリ

`modules/ecr-repository`

**役割**: スキャン有効、ライフサイクル（keep_last）、KMS（任意）、クロスアカウント Pull（任意）

**入力**

- `name`
- `keep_last` (number, default `10`)
- `kms_key_id` (optional)
- `pull_principals` (list(string), optional)

**出力**

- `repository_url`
- `repository_arn`

### 9.24 Transfer Family（VPC Hosted SFTP）

`modules/transfer-family`

**役割**: SFTP サーバ（VPC ホスト型）+ ユーザ（S3 連携）+ ログ

**入力**

- `vpc_id`
- `subnet_ids`
- `security_group_id`
- `s3_bucket`
- `users` (map(object({ name = string, role_arn = string, home_dir = string })))

**出力**

- `server_id`
- `endpoint`

### 9.25 DB 論理ダンプ → S3（スケジュール）

`modules/db-dump-to-s3`

**役割**: ECS スケジュールドタスク（EventBridge）で pg_dump / mysqldump を実行 → S3/KMS へ保存

**入力**

- `subnet_ids`
- `security_group_id`
- `vpc_id`
- `rds_secret_arn`（username/password/host/port/dbname を保持）
- `engine` ("postgresql" or "mysql")
- `s3_bucket`
- `s3_prefix`
- `schedule_expression`（例: "cron(0 18 * * ? *)"）
- `task_cpu`
- `task_memory`（軽量でOK）

**出力**

- `rule_arn`
- `task_definition_arn`

### 9.26 監視・可観測性ベースライン

`modules/observability-baseline`

**役割**: 代表的な CloudWatch アラームとダッシュボード（ALB 5xx、ECS CPU/Mem、RDS FreeStorage/Connections）

**入力**: 各メトリクスのしきい値（number, optional）、通知先 ARN（SNS）

**出力**

- `dashboard_name`
- `alarm_arns` (list)

### 9.27 Secrets ベースライン

`modules/secrets-baseline`

**役割**: アプリ/DB の Secrets Manager を簡単作成。Rotation はオプションで ON/OFF

**入力**: `secrets` (map(string|json)), `enable_rotation` (bool), `rotation_days` (number), `rotation_lambda_arn` (optional)

**出力**: `secret_arns` (map)

### 9.28 CI/CD（GitHub OIDC or CodePipeline 用ロール）

`modules/ci-oidc-deploy`

**役割**: デプロイ用 IAM Role（ECR Push、ECS UpdateService、SSM PutParameter）

**入力**

- GitHub OIDC の場合: `github_org`, `github_repo`, `role_name`
- CodePipeline の場合: `trusted_principal_arns`

**出力**: `role_arn`

### 9.29 Workload 最小構成サンプル（つなぎ込み順）

目的: 手を止めず最短で “アプリが社内から見える” ところまで

```hcl
# 1) ECR
module "ecr" {
  source = "../modules/ecr-repository"
  name   = "app"
}

# 2) Workload VPCE（ECS 必須分）
module "vpce" {
  source            = "../modules/workload-vpce"
  vpc_id            = module.dev_vpc.vpc_id
  subnet_ids        = flatten(values(module.dev_vpc.private_subnet_ids_by_az))
  security_group_id = module.dev_default_sg.id
}

# 3) WAF（ユーザ拠点のみ許可）
module "waf" {
  source      = "../modules/waf-acl"
  name        = "dev"
  allow_cidrs = ["172.0.0.0/16"]
}

# 4) RDS（Aurora Srv v2）
module "db" {
  source             = "../modules/rds"
  engine             = "aurora-postgresql"
  engine_version     = "15"
  vpc_id             = module.dev_vpc.vpc_id
  subnet_ids         = [for az, ids in module.dev_vpc.private_subnet_ids_by_az : ids[0]]
  ingress_sg_ids     = [] # アプリ SG を後で渡す
  serverless_min_acu = 0.5
  serverless_max_acu = 2
  backup_retention   = 7
}

# 5) ECS + ALB
module "api" {
  source            = "../modules/ecs-alb-service"
  service_name      = "api"
  vpc_id            = module.dev_vpc.vpc_id
  subnet_ids        = flatten(values(module.dev_vpc.private_subnet_ids_by_az))
  container_image   = "${module.ecr.repository_url}:latest"
  container_port    = 8080
  desired_count     = 2
  task_cpu          = 512
  task_memory       = 1024
  allowed_cidrs     = ["172.0.0.0/16"]
  health_check_path = "/health"
  waf_acl_arn       = module.waf.web_acl_arn
  secrets           = { DB_PASSWORD = module.db.secret_arn }
}

# 6) PHZ（api.svc.local → ALB）
module "svc_dns" {
  source    = "../modules/route53-phz-service"
  zone_name = "svc.local"
  vpc_id    = module.dev_vpc.vpc_id
  records = [{
    name          = "api"
    type          = "A"
    alias_zone_id = module.api.alb_zone_id
    alias_name    = module.api.alb_dns_name
  }]
}

# 7) 監視と DB ダンプ（任意で ON）
module "obs" {
  source       = "../modules/observability-baseline"
  # sns_topic_arn = "arn:aws:sns:..."
}
module "dump" {
  source              = "../modules/db-dump-to-s3"
  vpc_id              = module.dev_vpc.vpc_id
  subnet_ids          = flatten(values(module.dev_vpc.private_subnet_ids_by_az))
  security_group_id   = module.dev_default_sg.id
  rds_secret_arn      = module.db.secret_arn
  engine              = "postgresql"
  s3_bucket           = "dev-rds-dump"
  s3_prefix           = "pg/"
  schedule_expression = "cron(0 18 * * ? *)"
}
```

### 9.30 Workload 側 実装順（最短）

1. workload-vpce（ECS/ECR/Secrets/Logs/S3 GW）
2. waf-acl（許可 CIDR 固定）
3. rds（先に作ると Secret が固まる）
4. ecs-alb-service（WAF を渡す）
5. route53-phz-service（ALB Alias）
6. observability-baseline / db-dump-to-s3 / transfer-family（必要に応じて）
7. ci-oidc-deploy（配布線）
