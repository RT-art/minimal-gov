<div align="center">

# Minimal Gov

</div>
⭐ **AWS × Terraform × Terragrunt**

このリポジトリは、実務で触れていた環境を可能な限り模倣し、個人ポートフォリオとして構築した **IaC (Infrastructure as Code)** 一式です。

## 🧭 Architecture

![Architecture Diagram](./image/アーキテクチャ図.png)

Transit Gateway をハブとして `network` (共通 NW) と `workloads` (業務 VPC) を接続する構成です。
ワークロード側は **ALB + WAF** → **ECS(Fargate)** / **RDS(PostgreSQL)** / **PrivateHostZone** を利用しています。

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
├── envs
│   ├── dev # 開発環境用設定ファイル
│   │    └── env.hcl
│   └── prod # 本番環境用設定ファイル
│       └── env.hcl
│       ├── network # networkアカウントのトップレイヤー定義
│       │   ├── ec2 # EC2関連
│       │   ├── endpoint # VPCエンドポイント関連
│       │   ├── tgw_attachment # Transit Gatewayアタッチメント関連
│       │   ├── tgw_hub # Transit Gatewayハブ関連
│       │   ├── tgw_route # Transit Gatewayルート関連
│       │   ├── vpc # VPC関連
│       │   └── vpc_route_to_tgw # Transit GatewayへのVPCルート関連
│       └── workloads # workloadsアカウントのトップレイヤー定義
│           ├── alb # Application Load Balancer関連
│           ├── app # アプリケーション関連
│           ├── dns # DNS関連 (Route53など)
│           ├── ecr # Elastic Container Registry関連
│           ├── network # ワークロードVPCネットワーク関連
│           └── postgres # PostgreSQL (RDS) 関連
│ 
├── modules # 再利用可能なTerraformモジュール群
│   ├── compute # 計算リソース関連 (EC2, ECS Fargate, ECRなど)
│   │   ├── ec2_bastion # EC2 Bastionホストモジュール
│   │   ├── ecr # ECRモジュール
│   │   └── ecs_fargate # ECS Fargateモジュール
│   ├── grobal # グローバルリソース関連 (Organizations, SSO, OIDCなど)
│   │   ├── oidc # OIDCモジュール
│   │   ├── organizations # AWS Organizationsモジュール
│   │   └── scp # Service Control Policies (SCP) モジュール
│   ├── network # ネットワーク関連 (VPC, Transit Gateway, ALB/WAF, Route53など)
│   │   ├── alb_waf # ALB + WAFモジュール
│   │   ├── endpoint # VPCエンドポイントモジュール
│   │   ├── route53_private_zone # Route53プライベートゾーンモジュール
│   │   ├── tgw_hub # Transit Gatewayハブモジュール
│   │   ├── tgw_route # Transit Gatewayルートモジュール
│   │   ├── tgw_vpc_attachment # Transit Gateway VPCアタッチメントモジュール
│   │   ├── tgw_vpc_attachment_accepter # Transit Gateway VPCアタッチメント承認モジュール
│   │   ├── vpc # VPCモジュール
│   │   └── vpc_route_to_tgw # Transit GatewayへのVPCルートモジュール
│   └── storage # ストレージ関連 (RDS, S3 backendなど)
│       ├── backend # S3バックエンドモジュール
│       └── rds # RDSモジュール
│
└── organization # AWS Organizationsのトップレイヤー定義
    ├── organizations # Organizations管理関連
    │   ├── policies # Organizationsポリシー関連
    │   └── sso # SSO関連
    └── state_backend # Organizationsの状態管理用S3バックエンド

```

## ☁️ AWS Organization からの完全 IaC 化

マルチアカウント環境を模倣し、ランディングゾーンのセットアップから組織単位の管理まで **Terraform で一元管理** 可能にしています。

**SSO (Single Sign-On)** も Terraform で有効化できるようにしています。

![SSO Setup](./image/sso.png)

## 🧩 DRY 原則の徹底

**Terragrunt の DRY & Facade パターン** を採用することで、`input` に値を渡すだけで構築可能な、シンプルかつ再利用性の高い IaC を実現しました。

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

## 🚀 Quick Start

### 前提

- AWS 資格情報（`AWS_PROFILE` または `~/.aws/credentials`）が設定されていること。
- Terraform v1.13.3 および Terragrunt v0.87.3 がインストール済みであること。

### 初回セットアップ (pre-commit)

初回利用時には `pre-commit` を導入し、コード品質チェックを行います。

```bash
pipx install pre-commit # もしくは venv + pip
pre-commit install
pre-commit run --all-files # 全てのファイルに対してチェックを実行
```

### Plan の実行 (Applyは料金発生に注意)

各 `terragrunt.hcl` の `input` を編集し、以下のコマンドを実行してください。

```bash
cd infra/envs/prod

# ネットワーク領域 (順序制御しやすいよう個別/一括どちらも実行可能)
terragrunt run-all plan -include-dir network

# ワークロード領域
terragrunt run-all plan -include-dir workloads
```

## 🗺️ 今後の拡張（TODO）

- **GitHub Actions でマルチアカウント動作可能な差分駆動の plan/tfsec:** (OIDC は実装済み)
- **RDS 秘密情報の Secrets Manager 連携**


このリポジトリが、皆様の IaC 構築の一助となれば幸いです。ご意見やコントリビューションも歓迎いたします。

