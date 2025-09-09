# Minimal Gov Terraform Architecture Guide

このドキュメントは、Terraform で最小構成の政府系ネットワークを構築するための設計情報をまとめています。既存の設計思想はそのままに、AI コーディングエージェントが理解しやすいように構成を整理しました。

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

---

この設計をベースに、30–60 分でデモ環境を構築できます。追加でチェックリスト形式への整備が必要な場合は、別途検討してください。
