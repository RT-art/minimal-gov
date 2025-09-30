<div align="center">

# Minimal Gov

</div>
AWS × Terraform × Terragrunt – ガバナンスの効いた最小構成マルチアカウント / 閉域網 IaC ポートフォリオ

このリポジトリは、実務で触っていた環境を出来るだけ模して、個人ポートフォリオとして構築した IaC 一式です。
AWS のベストプラクティス（分離・最小権限・自動化）をできるだけシンプルな構成で再現し、ネットワーク分離 + ゲートウェイ集中（TGW） + WAF/ALB + ECS(Fargate) + RDS(PostgreSQL) + Private DNS を最小セットで動かします。

## 🧭Architecture

![Architecture Diagram](./image/アーキテクチャ図.png)

![Organization Diagram](./image/Organization.png)

Transit Gateway をハブにして network（共通 NW）と workloads（業務 VPC）を接続
ワークロード側は ALB+WAF → ECS(Fargate) / RDS(PostgreSQL) / PrivateHostZoneを使用


## 🔢Version



## ディレクトリ構成
```
infra/
envs/
dev|prod/
env.hcl
network/ # 共通NW（VPC, TGW, Endpoints 等）
vpc/
tgw_hub/ | tgw_attachment/ | tgw_route/
endpoint/ | vpc_route_to_tgw/
ec2/ #（必要に応じて踏み台など）
workloads/ # 業務VPC側（ALB/WAF, ECS, RDS, DNS）
alb/ | app/ | ecr/ | dns/
network/ # Workloads内の補助NW（必要に応じて）
vpc/ | endpoint/ | tgw_*/ | vpc_route_to_tgw/
postgres/


modules/ # Terraform modules（再利用可能な最小パーツ）
network/
vpc / endpoint / tgw_hub / tgw_route / route53_private_zone / alb_waf
compute/
ecs_fargate / ecr / ec2_bastion
strage/ # ※typo元ファイル名に合わせています（storage）
rds / backend
```

## AWS Organizationから完全Iac化
実務でのマルチアカウント環境を模して、ランディングゾーンから全てTerraformで管理可能

## DRY原則の徹底
terragruntによるdry＆faceadパターンにより、inputバリューを簡単に入力するだけで、構築可能

## 完全閉域網AWSネットワーク
Transit gatewayを使用し、複数VPC追加しても大丈夫なようにしている
エンドポイントを使用し、閉域網実現。
オンプレミスとの連携もカバーしており、ネットワークアカウントにinbound,outboundリゾルバを設置し、双方向の名前解決を可能にしています。

## コスト分析
管理アカウントでCost Export、クイックサイトを有効化させ、allアカウントのコスト分析をダッシュボードで管理可能にしています。
また、アテナによる詳細なクエリも可能にしています。

## pre-commitによるCI
完全個人で自走していたため、最初はgithubactionsでCIを回していましたが、開発効率が悪すぎたため、すべてpre-commitで回していました。
ベストプラクティスに沿った作りにしています。

## 前提ツール

## 

