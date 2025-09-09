![アーキテクチャ図](./image/アーキテクチャ図.png)
---
![Organization図](./image/Organization.png)

## 仕様

ユーザ（市役所職員と模擬）site-to-siteVPN→ネットワークアカウントのtgw→prod/devアカウントのecsアプリケーションへ、albを通じてアクセス。

運用保守→site-to-siteVPN→Networkアカウント内EC2→TGWアタッチメント＋ポートフォワーディング→prod,devの環境に到達し、操作

運用保守拠点はデータセンターで、AWS環境とIP重複が発生していると仮定。ssm接続し、ポートフォワーディングによってecs内部、rds内部に接続。

運用保守拠点内に、バックアップサーバを設置してあると想定。
prod環境のrdsからs3へ論理dmp出力→トランスファーファミリーでs3からdmpファイルをバックアップサーバに持ち込む→バックアップサーバでリストア。

aws環境は、エンドポイントでawsサービスと通信。

organizationで、セキュリティアカウントでセキュリティリソースを中央集権。

Route53はプライベートホストゾーン使用。
DNSリゾルバにより、オンプレ環境-AWS環境名前解決可能。
RAM共有で、すべてのVPCで名前解決可能。

## 全体像

3 アカウント（Security / Network / Prod+Dev）

Network VPC：踏み台 / TGW-Attach×2 / Resolver×2、SSM/EIC、必要最小限の VPCE（ssm 系＋logs/kms）

TGW：VGW, Network, Prod, Dev の 4 アタッチメント。専用 RT を 3 枚（VGW 用 / Network→Spoke 用 / Spoke→Network 用）

DNS：PHZ を Prod と Dev に作成し RAM 共有、Resolver In/Out でオンプレと疎通

ALB（Internal）＋ECS：ユーザ拠点 CIDR で ALB を制限、WAF 有効

RDS：論理ダンプを ECS タスク or Systems Manager Run Command で取得→S3

Transfer Family（VPC Hosted）→ オンプレ Backup サーバ

ログ：VPC/TGW/ALB/WAF/Trail を Security アカウント S3（KMS）へ

## 各アカウント設計

### ネットワークアカウント

VPC：192.168.0.0/16（インターネット未接続、IGW/NATGW なし）
AZ：2AZ（例：ap-northeast-1a/1c）

サブネット
bastion-a：192.168.10.0/24（EC2踏み台、VPCエンドポイント）
bastion-c：192.168.11.0/24

tgw-attach-a：192.168.50.0/28（TGW アタッチ用）
tgw-attach-c：192.168.50.16/28

resolver-in-a : 192.168.60.0/28
resolver-in-c : 192.168.60.16/28
resolver-out-a : 192.168.61.0/28
resolver-out-c : 192.168.61.16/28

endpoint-a : 192.168.20.0/28
endpoint-c : 192.168.21.0/28

vpc内ルートテーブル
bastion-a,cに紐づけ
192.168.0.0/16 → local
Prod/Dev 向け：10.0.0.0/16 → tgwを通る

tgw-attach-a,c
local

resolver-in,out
local

Transit Gateway (TGW)
市役所ユーザ → アプリだけ見える
運用者 → 踏み台から Prod/Dev に入れる
データセンター → SFTP バックアップだけ通す


アタッチメント計4つ：
att-user-vpn（ユーザ拠点 Site-to-Site VPN）
att-vgw（Ops/DC 側 VGW アタッチ）※VGW と TGW を接続
att-network-vpc（ネットワークアカウントVPC）
att-dev（Dev VPC）


ルートテーブル
rt-user（ユーザ向け）
関連付け：att-user-vpn
伝播許可：att-prod / att-dev
載せない：att-network-vpc / att-vgw
→ ユーザからは Prod/Dev だけ見える（ALB でCIDR制限＋WAF）

rt-spoke→network（Spoke から Network へ）
関連付け：att-prod, att-dev
伝播許可：att-network-vpc, att-user-vpn
→ Prod/Dev 側の戻り道（ユーザ/Network への復路）を作る

rt-network→spoke（Network から Spoke へ）
関連付け：att-network-vpc
伝播許可：att-prod, att-dev
→ 踏み台 EC2 から Spoke（ECS/RDS 等）へ

DC（VGW）経路の扱い
Transfer Family 用のサブネット (/26) だけを TGW に広告（「この道だけ AWS に来てね」と指定）。
DC 側には「10.0.0.0/16（自分のネットワーク）」と「10.0.20.0/26（AWS の Transfer サブネット）」の2つがある。
ルーティングのルールで より長い /26 が優先されるので、SFTP の通信だけ AWS に来る。
他の 10.0.0.0/16 宛は DC 内にとどまる


Site-to-Site VPN
ユーザ拠点 → TGW（att-user-vpn）
ルート広告：Prod/Dev のみ（ALB 経由でアプリ閲覧）
Ops/DC → VGW（Network VPC）
ルート広告：Network VPC（192.168.0.0/16） と、（必要時のみ）Prod の Transfer 用サブネットの more specific（例 /26）
トンネルは本静的ルート（シンプル）。BGP なら prefix-list で /26 のみ許可。
運用作業は SSM セッション経由（VPN 経由の SSH は不使用）。バックアップは Transfer Family（VPC hosted） 宛のみ DC から通す。


踏み台兼オペレーション EC2
用途：SSM 経由でログイン、Port Forwarding で ECS/RDS へ到達

配置：bastion-a,c、パブリックIP無し

OS/サイズ：AL2023 / t3.small

IAM ロール：AmazonSSMManagedInstanceCore + S3/CloudWatchLogs への最小権限

SSM 関連：ドキュメント AWS-StartPortForwardingSessionToRemoteHost を使用

例：RDS に 5432/TCP フォワード

aws ssm start-session \
  --target i-xxxxxxxx \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters host="10.0.12.34",portNumber="5432",localPortNumber="15432"

ECS タスク ENI へも同様（タスクIP/ポートを指定）
セキュリティグループ（最小）
Inbound：なし（SSM 経由のため不要）
Outbound：
ssm, ssmmessages, ec2messages, logs, kms VPCエンドポイントのSGへ
Prod/Dev CIDR（10.0.0.0/16）→ tgw（踏み台→Spoke 通信用）

 VPC エンドポイント
Interface：ssm / ssmmessages / ec2messages / logs / kms/EC2 instance connect

サブネット：endpoint-a,c
SG：踏み台 EC2 からの 443 のみ許可


DNA
Inbound/Outbound Endpoints：resolver-in-* / resolver-out-*
フォワードルール
onprem.example.local → Ops/DC の DNS（Outbound）
AWS Private Zone 名（例：prod.internal, dev.internal） は PHZ を Prod/Dev に作成し RAM 共有。
各 VPC のデフォルトリゾルバを使い、Network VPC からも名前解決可。
オンプレ → AWS 名解決：オンプレDNS から Inbound Endpoint 宛にフォワード


セキュリティ（最小で中央集約）
ログ出力先：Security アカウントの S3（KMS 暗号化）
VPC Flow Logs（Network VPC）
Transit Gateway Flow Logs（TGW 全体）
ALB/WAF/CloudTrail は各アカウントから同 S3 に集約（本設計外だが前提）
KMS：Organization 共有の CMK（Security 側）を参照

アクセス境界
ユーザ拠点→Prod/Dev の ALB のみ（ALB SG/WAF でユーザ CIDR を許可）
Ops/DC → Transfer Family 用サブネットのみ（TGW ルートと SG でピンポイント化）
踏み台 EC2 → Spoke 全体（運用都合上。ただし SG で最小化）


バックアップ経路（RDS→S3→Transfer→DC）
RDS 論理ダンプ：ECS タスク or SSM Run Command で S3（Prodの専用バケット）へ出力
Transfer Family（VPC Hosted）：Prod VPC 内 NLB/ENI を 専用 /26 に配置
TGW ルート：att-vgw に対し /26 のみ Spoke（Prod）へスタティック追加
Ops/DC：オンプレ側に同じ /26 の静的経路（または BGP で許可）を入れる
SG：Transfer の SG は DC のバックアップサーバ /32 のみ 22/端口許可（SFTP/FTPS）
これで 重複 CIDR を崩さず、DC からは Transfer だけに到達可能。運用作業は引き続き SSM ポートフォワード。


リソース作成順番
TGW 作成（3 ルートテーブル：rt-user / rt-spoke→network / rt-network→spoke）
Network VPC（サブネット作成 → tgw attach / resolver in/out / mgmt 用 rt）
VPC エンドポイント（ssm 系＋logs/kms）、踏み台 EC2、IAM ロール
ユーザ拠点 VPN（→TGW）：att-user-vpn を rt-user に関連付け
Ops/DC VPN（→VGW→TGW）：att-vgw を作成、Transfer 用 /26 のみ通す
Prod/Dev 側アタッチ と rt-spoke→network 連携（復路含め）
Resolver 設定（オンプレ連携・PHZ 共有）
FlowLogs/TGW Logs を Security S3 へ




