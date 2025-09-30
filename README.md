<div align="center">

# Minimal Gov

</div>
AWS/Terraform/Terragrunt を使った IaCポートフォリオです。
ガバナンスの効いた閉域網マルチアカウント環境を、ミニマルな規模で実装しました。

## Architecture

![Architecture Diagram](./image/アーキテクチャ図.png)

![Organization Diagram](./image/Organization.png)

## Version

- Terraform/Provider versions
  - Terraform: `>= 1.9.0, < 2.0.0`
  - AWS Provider: `~> 6.14`

## ディレクトリ構成
```
└── infra
    ├── envs
    │   ├── dev
    │   │   ├── env.hcl
    │   │   ├── network
    │   │   │   ├── ec2
    │   │   │   │   └── terragrunt.hcl
    │   │   │   ├── endpoint
    │   │   │   │   └── terragrunt.hcl
    │   │   │   ├── tgw_attachment
    │   │   │   │   └── terragrunt.hcl
    │   │   │   ├── tgw_hub
    │   │   │   │   └── terragrunt.hcl
    │   │   │   ├── tgw_route
    │   │   │   │   └── terragrunt.hcl
    │   │   │   ├── vpc
    │   │   │   │   └── terragrunt.hcl
    │   │   │   └── vpc_route_to_tgw
    │   │   │       └── terragrunt.hcl
    │   │   └── workloads
    │   │       ├── alb
    │   │       │   └── terragrunt.hcl
    │   │       ├── app
    │   │       │   └── terragrunt.hcl
    │   │       ├── dns
    │   │       │   └── terragrunt.hcl
    │   │       ├── ecr
    │   │       │   └── terragrunt.hcl
    │   │       ├── network
    │   │       │   ├── endpoint
    │   │       │   │   └── terragrunt.hcl
    │   │       │   ├── tgw_attachment
    │   │       │   │   └── terragrunt.hcl
    │   │       │   ├── tgw_hub
    │   │       │   │   └── terragrunt.hcl
    │   │       │   ├── vpc
    │   │       │   │   └── terragrunt.hcl
    │   │       │   └── vpc_route_to_tgw
    │   │       │       └── terragrunt.hcl
    │   │       └── postgres
    │   │           └── terragrunt.hcl
    │   └── prod
    │       ├── env.hcl
    │       ├── network
    │       │   ├── ec2
    │       │   │   └── terragrunt.hcl
    │       │   ├── endpoint
    │       │   │   └── terragrunt.hcl
    │       │   ├── tgw_attachment
    │       │   │   └── terragrunt.hcl
    │       │   ├── tgw_hub
    │       │   │   └── terragrunt.hcl
    │       │   ├── tgw_route
    │       │   │   └── terragrunt.hcl
    │       │   ├── vpc
    │       │   │   └── terragrunt.hcl
    │       │   └── vpc_route_to_tgw
    │       │       └── terragrunt.hcl
    │       └── workloads
    │           ├── alb
    │           │   └── terragrunt.hcl
    │           ├── app
    │           │   └── terragrunt.hcl
    │           ├── dns
    │           │   └── terragrunt.hcl
    │           ├── ecr
    │           │   └── terragrunt.hcl
    │           ├── network
    │           │   ├── endpoint
    │           │   │   └── terragrunt.hcl
    │           │   ├── tgw_attachment
    │           │   │   └── terragrunt.hcl
    │           │   ├── vpc
    │           │   │   └── terragrunt.hcl
    │           │   └── vpc_route_to_tgw
    │           │       └── terragrunt.hcl
    │           └── postgres
    │               └── terragrunt.hcl
    ├── modules
    │   ├── compute
    │   │   ├── ec2_bastion
    │   │   │   ├── main.tf
    │   │   │   └── variables.tf
    │   │   ├── ecr
    │   │   │   ├── main.tf
    │   │   │   ├── outputs.tf
    │   │   │   └── variables.tf
    │   │   └── ecs_fargate
    │   │       ├── main.tf
    │   │       ├── outputs.tf
    │   │       └── variables.tf
    │   ├── grobal
    │   │   ├── oidc
    │   │   │   ├── main.tf
    │   │   │   └── variables.tf
    │   │   ├── organizations
    │   │   │   ├── local.tf
    │   │   │   ├── main.tf
    │   │   │   ├── outputs.tf
    │   │   │   └── variables.tf
    │   │   └── scp
    │   │       ├── main.tf
    │   │       ├── policies
    │   │       │   ├── deny_all_suspended.json
    │   │       │   ├── deny_disable_security_services.json
    │   │       │   ├── deny_leaving_org.json
    │   │       │   ├── deny_root.json
    │   │       │   └── deny_unapproved_regions.json
    │   │       └── variables.tf
    │   ├── network
    │   │   ├── alb_waf
    │   │   │   ├── main.tf
    │   │   │   ├── outputs.tf
    │   │   │   └── variables.tf
    │   │   ├── endpoint
    │   │   │   ├── local.tf
    │   │   │   ├── main.tf
    │   │   │   ├── outputs.tf
    │   │   │   └── variables.tf
    │   │   ├── route53_private_zone
    │   │   │   ├── main.tf
    │   │   │   ├── outputs.tf
    │   │   │   └── variables.tf
    │   │   ├── tgw_hub
    │   │   │   ├── main.tf
    │   │   │   ├── outputs.tf
    │   │   │   └── variables.tf
    │   │   ├── tgw_route
    │   │   │   ├── main.tf
    │   │   │   ├── outputs.tf
    │   │   │   └── variables.tf
    │   │   ├── tgw_vpc_attachment
    │   │   │   ├── main.tf
    │   │   │   ├── outputs.tf
    │   │   │   └── variables.tf
    │   │   ├── tgw_vpc_attachment_accepter
    │   │   │   ├── main.tf
    │   │   │   ├── outputs.tf
    │   │   │   └── variables.tf
    │   │   ├── vpc
    │   │   │   ├── main.tf
    │   │   │   ├── outputs.tf
    │   │   │   └── variables.tf
    │   │   └── vpc_route_to_tgw
    │   │       ├── main.tf
    │   │       ├── outputs.tf
    │   │       └── variables.tf
    │   └── strage
    │       ├── backend
    │       │   ├── local.tf
    │       │   ├── main.tf
    │       │   ├── outputs.tf
    │       │   └── variables.tf
    │       └── rds
    │           ├── main.tf
    │           ├── outputs.tf
    │           └── variables.tf
    └── organization
        ├── oidc
        │   ├── dev
        │   └── prod
        │       ├── network
        │       └── workloads
        ├── organizations
        │   ├── README.md
        │   ├── backend.tf
        │   ├── main.tf
        │   ├── outputs.tf
        │   ├── policies
        │   │   └── deny_disable_cloudtrail.json
        │   ├── provider.tf
        │   ├── sso
        │   │   ├── README.md
        │   │   ├── backend.tf
        │   │   ├── main.tf
        │   │   ├── provider.tf
        │   │   ├── ssouser
        │   │   │   ├── README.md
        │   │   │   ├── backend.tf
        │   │   │   ├── main.tf
        │   │   │   └── terraform.tfvars
        │   │   ├── terraform.tfvars
        │   │   └── variables.tf
        │   ├── terraform.tfvars
        │   └── variables.tf
        └── state_backend
            ├── README.md
            ├── backend.tf
            ├── main.tf
            ├── outputs.tf
            ├── provider.tf
            ├── terraform.tfvars
            └── variables.tf
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

