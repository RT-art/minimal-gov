

## 仕様

- **ユーザ（市役所職員と模擬）**  
  site-to-siteVPN → ネットワークアカウントの TGW → prod/dev アカウントの ECS アプリケーションへ、ALB を通じてアクセス。

- **運用保守**  
  site-to-siteVPN → Network アカウント内 EC2 → TGW アタッチメント＋ポートフォワーディング → prod/dev の環境に到達し、操作。  

- **運用保守拠点**  
  データセンターで AWS 環境と IP 重複が発生していると仮定。SSM 接続し、ポートフォワーディングによって ECS 内部、RDS 内部に接続。

- 運用保守拠点内にバックアップサーバを設置。  
  Prod 環境の RDS から S3 へ論理 DMP 出力 → Transfer Family で S3 から DMP ファイルをバックアップサーバに持ち込む → バックアップサーバでリストア。

- AWS 環境は、エンドポイントで AWS サービスと通信。

- **Organization** でセキュリティアカウントにセキュリティリソースを中央集権。

- **Route53** はプライベートホストゾーン使用。  
  DNS リゾルバにより、オンプレ環境 - AWS 環境名前解決可能。  
  RAM 共有で、すべての VPC で名前解決可能。

# アーキテクチャ設計

![アーキテクチャ図](./image/アーキテクチャ図.png)  
![Organization図](./image/Organization.png)

## 全体像

- **アカウント構成**: 3 アカウント（Security / Network / Prod+Dev）

- **Network VPC**  
  踏み台 / TGW-Attach×2 / Resolver×2、SSM/EIC、必要最小限の VPCE（ssm 系＋logs/kms）

- **TGW**  
  VGW, Network, Prod, Dev の 4 アタッチメント。専用 RT を 3 枚（VGW 用 / Network→Spoke 用 / Spoke→Network 用）

- **DNS**  
  PHZ を Prod と Dev に作成し RAM 共有、Resolver In/Out でオンプレと疎通

- **ALB（Internal）＋ECS**  
  ユーザ拠点 CIDR で ALB を制限、WAF 有効

- **RDS**  
  論理ダンプを ECS タスク or Systems Manager Run Command で取得 → S3

- **Transfer Family（VPC Hosted）**  
  オンプレ Backup サーバに転送

- **ログ**  
  VPC/TGW/ALB/WAF/Trail を Security アカウント S3（KMS）へ

## 各アカウント設計

### ネットワークアカウント

- **VPC**  
  192.168.0.0/16（インターネット未接続、IGW/NATGW なし）  
  AZ：2AZ（ap-northeast-1a/1c）

- **サブネット**
  - bastion-a：192.168.10.0/24（EC2 踏み台、VPC エンドポイント）
  - bastion-c：192.168.11.0/24
  - tgw-attach-a：192.168.50.0/28（TGW アタッチ用）
  - tgw-attach-c：192.168.50.16/28
  - resolver-in-a：192.168.60.0/28
  - resolver-in-c：192.168.60.16/28
  - resolver-out-a：192.168.61.0/28
  - resolver-out-c：192.168.61.16/28
  - endpoint-a：192.168.20.0/28
  - endpoint-c：192.168.21.0/28

- **ルートテーブル**
  - bastion-a,c  
    - 192.168.0.0/16 → local  
    - Prod/Dev 向け：10.0.0.0/16 → TGW
  - tgw-attach, resolver → local

- **Transit Gateway**
  - アタッチメント計 4 つ  
    - att-user-vpn（ユーザ拠点 Site-to-Site VPN）  
    - att-vgw（Ops/DC 側 VGW アタッチ）  
    - att-network-vpc（ネットワークアカウント VPC）  
    - att-dev（Dev VPC）
  - ルートテーブル  
    - rt-user：ユーザ向け（Prod/Dev のみ）  
    - rt-spoke→network：Prod/Dev から Network への復路  
    - rt-network→spoke：踏み台から Spoke への経路

- **Site-to-Site VPN**
  - ユーザ拠点 → TGW（att-user-vpn）  
  - Ops/DC → VGW（Network VPC）

- **踏み台 EC2**
  - 配置：bastion-a,c  
  - OS：AL2023 / t3.small  
  - IAM：AmazonSSMManagedInstanceCore + S3/CloudWatchLogs  
  - 接続：SSM Port Forwarding

- **VPC エンドポイント**
  - ssm / ssmmessages / ec2messages / logs / kms / EC2 instance connect

- **DNS**
  - Inbound/Outbound Endpoints  
  - onprem.example.local → Ops/DC DNS  
  - AWS 内部ドメイン → PHZ 共有

- **セキュリティ**
  - ログ集約：Security アカウントの S3（KMS）  
  - Flow Logs, TGW Logs, ALB/WAF/CloudTrail

- **バックアップ経路**
  - RDS → S3 → Transfer Family → DC バックアップサーバ

- **リソース作成順序**
  1. TGW 作成（3 RT）  
  2. Network VPC（Attach/Resolver）  
  3. VPCE・踏み台 EC2  
  4. VPN 設定  
  5. Prod/Dev アタッチ  
  6. Resolver 設定  
  7. ログ集約

### Prod/Dev アカウント

- **VPC**
  - Prod：10.0.0.0/16  
  - Dev：10.2.0.0/16  
  - AZ：ap-northeast-1a/1c

- **サブネット（共通パターン）**
  - ALB：10.x.1.0/24, 10.x.2.0/24  
  - ECS(app)：10.x.10.0/24, 10.x.11.0/24  
  - RDS(db)：10.x.20.0/24, 10.x.21.0/24  
  - VPC Endpoint：10.x.30.0/27, 10.x.30.32/27  
  - Prod のみ：Transfer Family → 10.0.20.0/26, 10.0.20.64/26

- **ALB**
  - Internal / HTTPS:443  
  - SG：ユーザ拠点 CIDR のみ許可  
  - WAF：Prod 必須

- **ECS**
  - Fargate / AZ 分散  
  - ログ：CloudWatch Logs  
  - ECR：スキャン有効

- **RDS**
  - Prod：Multi-AZ  
  - Dev：Single-AZ  
  - エンジン：PostgreSQL or MySQL  
  - SG：ECS からのみ許可  
  - バックアップ：S3 へ論理ダンプ

- **Transfer Family（Prod のみ）**
  - SFTP / サブネット：10.0.20.0/26  
  - SG：DC バックアップサーバ /32 のみ 22 許可  
  - S3：prod-backup-bucket（KMS）

- **VPC Endpoint**
  - Interface：ssm, ssmmessages, ec2messages, logs, kms, ecr.api, ecr.dkr, secretsmanager  
  - Gateway：s3, dynamodb

- **Route53**
  - PHZ：  
    - Prod → `prod.internal`  
    - Dev → `dev.internal`  
  - レコード例：  
    - app.prod.internal → ALB  
    - db.prod.internal → RDS

- **ログ出力**
  - CloudTrail, VPC Flow Logs, TGW, ALB/WAF Logs → Security アカウント S3（KMS）

- **IAM ロール**
  - ECS タスクロール：Secrets Manager 読取, S3 書込  
  - 踏み台 EC2 ロール：AmazonSSMManagedInstanceCore + logs:Put*  
  - デプロイロール：ECR push, ECS update-service

## オンプレ構築（デモ用）
1. VPC & サブネット

ユーザ拠点 VPC: 172.0.0.0/16

172.0.10.0/24 (cg)

172.0.20.0/24 (client)

運用保守 VPC（重複再現版）: 10.0.0.0/16

10.0.10.0/24 (cg)

10.0.20.0/24 (backup)

※ 重複不要なら 10.200.0.0/16 を使用

2. EC2 インスタンス
名称	AMI	サイズ	要件
user-cgw	strangswanwo	t3.small	EIP付与, Src/Dst Check無効, UDP 500/4500
ops-cgw	strangswanwo	t3.small	同上
user-client	AL2023	t3.micro	疑似ユーザ端末
backup-server	AL2023	t3.small	バックアップ取得用

セキュリティグループ

CGW: UDP 500/4500, ICMP

client/backup: Outbound All, Inbound SSH

3. VPN (AWS 側)

ユーザ拠点 → TGW

宛先: 10.0.0.0/16, 10.2.0.0/16

運用保守 → VGW

宛先: 192.168.0.0/16

4. ルーティング

ユーザ拠点 VPC

10.0.0.0/16, 10.2.0.0/16 → user-cgw

運用保守 VPC

192.168.0.0/16 → ops-cgw

5. strongSwan 設定
OS 設定
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv4.conf.all.accept_redirects=0
sudo sysctl -w net.ipv4.conf.all.send_redirects=0

ユーザ拠点 /etc/ipsec.conf
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

運用保守 /etc/ipsec.conf
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

secrets
<LEFT_EIP> <TUN1_REMOTE> : PSK "<PSK>"
<LEFT_EIP> <TUN2_REMOTE> : PSK "<PSK>"

6. バックアップ経路（CIDR重複あり）

backup-server → (VPN to VGW) → Network踏み台EC2 → (TGW) → Transfer Family

SSH 設定例:

Host bastion
  HostName <Network_VPC_Bastion_PrivateIP>
  User ec2-user
  IdentityFile ~/.ssh/bastion.pem

Host tf
  HostName <Transfer_Family_PrivateIP>
  User sftp-user


SFTP 実行例:

sftp -o ProxyJump=bastion tf:/export/xxxx.dmp /data/restore/

7. 構築手順（最短）

VPC作成（ユーザ拠点 / 運用保守）

IGWアタッチ + 公開サブネット作成

EC2起動（strangswanwo AMI）、EIP割当、Src/Dst Check無効

SG設定（UDP500/4500）

AWS側VPN作成（TGW, VGW）

strongSwan設定投入 & 再起動

オンプレVPCルート設定

DNS設定（ユーザ拠点は Inbound Resolver）

必要なら backup-server 起動

👉 これをベースにすれば、30–60分でデモ環境を構築できます。

要望に合わせて、この抽出をさらに **「チェックリスト形式」**に落とし込みますか？