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
- 運用保守拠点と Workloads 環境であえて IP を重複させ、実務をリアルに再現
- IP 重複を回避するため、SSM による L4 通信・ポートフォワーディングを使用

### DNS
- Route53 プライベートホストゾーンによるマルチアカウント間の名前解決
- ネットワークアカウントにリゾルバエンドポイントを設置し、オンプレと AWS 間の名前解決を実現

### Security
- 全通信を暗号化
- ALB + WAF による本番環境への不正アクセス拒否

### Terraform Coding
- Module による再利用性を確保
- ファサードパターンを活用し、ルートモジュールをシンプルに保ちつつ柔軟なリソース定義を実現

### CI/CD
- Terraform の `fmt`, `validate`, `lint`, `plan`, `tftrivy` を PR 作成時に自動実行
- main ブランチへのマージで `apply` を実行
- アプリケーションは `build → push(ECR) → deploy(ECS)` のブルー/グリーンまたはローリングデプロイ

## Repository Structure

```
.
├── infra
│   ├── modules       # Reusable Terraform modules
│   └── live          # Sample environment definitions
├── image             # Architecture diagrams
└── readme.md         # This file
```
