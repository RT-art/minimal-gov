<div align="center">

# Minimal Gov

</div>

**AWS × Terraform × Terragrunt**

このリポジトリは、実務で触れていた環境を可能な限り模倣し、個人ポートフォリオとして構築した **IaC (Infrastructure as Code)** 一式です。

## 🧭 Architecture

![Architecture Diagram](./image/アーキテクチャ図.png)

## 🔢 Version

| Name | Version |
|---|---|
| Terraform | v1.13.3 |
| Terragrunt | v0.87.3 |
| Lint/Sec | tflint, trivy |
| Git hooks | pre-commit（fmt / validate / tflint / trivy / docs） |

## 📂ディレクトリ構成

```
terraform
├── organization # <--- Organization entrypoint(management account)
│    ├── organizations 
│    │   ├── policies 
│    │   └── sso 
│    └── state_backend
│ 
├── envs
│   ├── dev
│   └── prod
│       ├── env.hcl
│       ├── network # <--- Network account entrypoint
│       │   ├── ec2 
│       │   ├── endpoint 
│       │   ├── tgw_attachment 
│       │   ├── tgw_hub 
│       │   ├── tgw_route 
│       │   ├── vpc 
│       │   └── vpc_route_to_tgw 
│       │ 
│       └── workloads # <--- Workload account entrypoint
│           ├── alb 
│           ├── app 
│           ├── dns 
│           ├── ecr 
│           ├── network
│           │   ├── endpoint
│           │   ├── tgw_attachment
│           │   ├── tgw_hub
│           │   ├── vpc
│           │   └── vpc_route_to_tgw
│           └── postgres 
│ 
├── modules # <--- modules
│   ├── compute 
│   │   ├── ec2_bastion 
│   │   ├── ecr 
│   │   └── ecs_fargate 
│   ├── grobal 
│   │   ├── oidc 
│   │   ├── organizations
│   │   └── scp 
│   ├── network
│   │   ├── alb_waf
│   │   ├── endpoint 
│   │   ├── route53_private_zone 
│   │   ├── tgw_hub 
│   │   ├── tgw_route 
│   │   ├── tgw_vpc_attachment 
│   │   ├── tgw_vpc_attachment_accepter
│   │   ├── vpc # VPCモジュール
│   │   └── vpc_route_to_tgw 
│   └── storage 
│       ├── backend 
│       └── rds 
│
```

## ☁️ AWS Organization からの完全 IaC 化
![SSO Setup](./image/Organization.png)
マルチアカウント環境を模倣し、ランディングゾーンのセットアップから組織単位の管理まで **Terraform で一元管理** 可能にしています。

**SSO (Single Sign-On)** も Terraform で有効化できるようにしています。

![SSO Setup](./image/sso.png)

## 🧩 DRY 原則の徹底

**Terragrunt** を採用することで、`input` に値を渡すだけで構築可能な、シンプルかつ再利用性の高い IaC を実現しました。

`env.hcl` の値を修正するだけで、`prod` / `dev` 環境の切り替えが可能です。

`terragrunt plan -all` を各アカウントのルートディレクトリで実行するだけで、すべての AWS リソースが作成されます。
依存リソースが作成されていなくても `plan` が通るように調整しています。

![Terragrunt Plan](./image/plan.png)

## 🔒 完全閉域網 AWS ネットワーク

**Transit Gateway** を利用し、複数 VPC の拡張に対応可能なネットワーク構成です。
**VPC エンドポイント** を活用して完全閉域網を構築しています。
オンプレミス連携を想定し、ネットワークアカウントに **Inbound/Outbound Resolver** を配置することで、双方向の名前解決を可能にしています。

### 💡 想定されるユーザー

- **金融機関 / 公共系システム:** 閉域網で個人情報を扱い、外部公開せずに VPN / 専用線経由でアクセスするケース。
- **エンタープライズの社内システム:** 社員専用の人事・経理アプリケーションなど、インターネット公開が不要で社内 VPN のみでアクセスするケース。
- **製造業 / 医療分野の研究システム:** 機密設計データや医療データを保護するため閉域化し、オンプレミス連携も容易に行いたいケース。

## 📊 コスト分析
管理アカウントで **Cost Export** と **QuickSight** を有効化し、全アカウントのコスト分析をダッシュボードで一元管理できるようにしています。

![Cost Dashboard](./image/costdashboad.png)

また、**Athena** による詳細なクエリも可能です。

![Athena Query](./image/athena.png)

## ⚙️ pre-commit による CI

当初は GitHub Actions で CI を回していましたが、開発効率を考慮し、現在はすべてのチェックを **pre-commit** で実行しています。
ベストプラクティスに沿った構成を維持しています。

![Pre-commit CI](./image/pre-commit.png)

## qiita
https://qiita.com/rt-art/items/c54d0cea114c0ee72122

https://qiita.com/rt-art/items/c6364d90b1546e92db57

https://qiita.com/rt-art/items/2d30cf249bab75bf73f9

https://qiita.com/rt-art/items/4153e5673a18cb487d6d

## 🗺️ 今後の拡張（TODO）

- **GitHub Actions でマルチアカウント動作可能な差分駆動の plan/tfsec:** (OIDC は実装済み)
- **RDS 秘密情報の Secrets Manager 連携**

