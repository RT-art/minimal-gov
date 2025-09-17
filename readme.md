# Minimal Gov

このプロジェクトは、私が実務で設計・構築した AWS 環境をミニマル化し、ポートフォリオとしてまとめたものです。

## Architecture

![Architecture Diagram](./image/アーキテクチャ図.png)

## Features

### Multi Accounts
- AWS Organizations を Terraform で完全に管理
- ベストプラクティスに沿ったマルチアカウント分離を実現  
![Organization Diagram](./image/Organization.png)

### Networking
- 完全閉域網ネットワークを構築
- TGW + Site-to-Site VPN を用いた AWS とオンプレのハイブリッドクラウド
- 運用保守拠点とAWS環境が、IP重複が発生していることをケアするため、SSMによる保守を前提にしています。

### DNS
- Route53 プライベートホストゾーンによるマルチアカウント間の名前解決
- ネットワークアカウントにリゾルバエンドポイントを設置し、オンプレと AWS 間の名前解決を実現

### Security
- ALB + WAF による本番環境への不正アクセス拒否

### Terraform Coding
- Module による再利用性を確保
- ファサードパターンを活用し、ルートモジュールをシンプルに保ちつつ柔軟なリソース定義を実現

## Repository Structure

```
.
├── infra
│   ├── modules       # Reusable Terraform modules
│   └── live          # Sample environment definitions
├── image             # Architecture diagrams
└── readme.md         # This file
```

## Terragrunt Workflow

ネットワークアカウントでは Terragrunt を利用してモジュール間の依存関係を解決しています。以下の手順で VPC モジュールとエンドポイントモジュールを組み合わせた `plan` を実行できます。

1. Terragrunt をインストールします（例: `go install github.com/gruntwork-io/terragrunt@latest`）。
2. AWS の認証情報とリージョンを環境変数に設定します。
3. ネットワーク環境ディレクトリに移動します。
   ```bash
   cd infra/envs/network
   ```
4. 依存関係を含めた `plan` を実行します。`vpc` と `endpoint` の両方を対象にすることで、VPC 出力を Terragrunt の依存関係として解決しながら計画を確認できます。
   ```bash
   terragrunt run-all plan \
     --terragrunt-include-dir vpc \
     --terragrunt-include-dir endpoint
   ```

`terragrunt run-all plan` は依存関係の順序（VPC → Endpoint）に従って各モジュールの `plan` を実行します。`endpoint` モジュールでは `mock_outputs` を定義しているため、VPC が未適用の状態でも依存関係の解決が可能です。
