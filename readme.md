![アーキテクチャ図](./image/アーキテクチャ図.png)
---
![Organization図](./image/Organization.png)

## 仕様

・ユーザ（市役所職員と模擬）site-to-siteVPN→ネットワークアカウントのtgw→prod/devアカウントのecsアプリケーションへ、albを通じてアクセス。

・運用保守の人→site-to-siteVPN→OPSアカウントVGWでOpsアカウントに到達→PrivatelinkでNetworkアカウント内NLBに通信→Networkアカウント内NLBからEC2に送信→TGWアタッチメントにより、NetworkアカウントのTGWに到達→prod,devの環境に到達し、操作

運用保守拠点はデータセンターで、AWS環境とIP重複が発生していると仮定し、Plivatelinkで重複を無視した通信をデモする。

運用保守拠点内に、バックアップサーバを設置してあると想定。prod環境のrdsからトランスファーファミリーでdmpファイルをバックアップサーバに持ち込み、リストアをかけて、オンプレバックアップ可能。

prod/dev環境は、エンドポイントでawsサービスと通信。

organizationで、セキュリティアカウントでセキュリティリソースを中央集権。

DNSリゾルバにより、すべてのアカウントでプライベートホストゾーン名前解決可能。

## 詳細設計

・ネットワークアカウント
vpc　192.168.0.0/16
subnet×3
EC2subnet 192.168.0.0/24
NLBsubnet 192.168.32.0/24
Endpointsubnet 192.168.224.0/24

TGW 
TGWアタッチメント→EC2subnetに紐づけ(endpointsubnetでもいいかも)
TGWルートテーブル 
ユーザ環境 172.0.0.0/16
prod/dev環境 10.0.0.0/16
Ops通信用endpoint

EC2
通信用のため、無料利用枠のamazonlinux

NLB
Opsからのprivatelink通信の受け手

Route53
InboundEndpoint
OutboundEndpoint
→ローカルホストゾーンはどこに置くか？（prod/dev環境？）

