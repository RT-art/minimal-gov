# Network Modules

VPC、ALB、Transit Gateway など、ネットワーク階層の共通部品を提供するモジュールです。

- `alb_waf`: プライベート ALB と関連セキュリティグループ、WAFv2 の ACL を構成します。
- `endpoint`: VPC エンドポイントと専用セキュリティグループをまとめて作成します。
- `route53_private_zone`: プライベートホストゾーンとレコードセットを管理します。
- `tgw_hub`: Transit Gateway 本体と AWS RAM を構成し、共有設定を行います。
- `tgw_route`: Transit Gateway のルートテーブル、関連付け、伝播設定を定義します。
- `tgw_vpc_attachment`: VPC を Transit Gateway にアタッチし、各種サポート設定を制御します。
- `tgw_vpc_attachment_accepter`: 共有された Transit Gateway アタッチメントを承認します。
- `vpc`: プライベートサブネットを持つ VPC とルートテーブルを作成します。
- `vpc_route_to_tgw`: 既存ルートテーブルへ Transit Gateway 向けルートを追加します。
