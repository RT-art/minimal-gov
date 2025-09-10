# Minimal Gov Terraform Architecture Guide

## 1. 仕様

### 1.1 ユーザ（市役所職員）
- site-to-site VPN → Network アカウントの TGW → Prod / Dev アカウントの ECS アプリケーションへ ALB 経由でアクセス

### 1.2 運用保守
- site-to-site VPN → Network アカウント内 EC2 → TGW アタッチメント + ポートフォワーディング → Prod / Dev 環境へ到達

### 1.3 運用保守拠点
- オンプレと AWS で IP 重複を想定。SSM 接続 + ポートフォワーディングで ECS / RDS へ接続
- バックアップサーバを設置
- Prod RDS → S3（論理ダンプ）→ Transfer Family → バックアップサーバでリストア
- AWS サービスとの通信はすべて VPC エンドポイント経由
- Organization を用いてセキュリティアカウントにセキュリティリソースを集約
- Route53 はプライベートホストゾーンを使用し、DNS リゾルバ + RAM で全 VPC から名前解決可能

## 2. アーキテクチャ設計

### 2.1 図
![アーキテクチャ図](./image/アーキテクチャ図.png)  
![Organization図](./image/Organization.png)

### 2.2 全体像
- **アカウント構成**: Security / Network / Prod+Dev の 3 アカウント
- **Network VPC**: 踏み台、TGW Attach×2、Resolver×2、SSM/EIC、必要最小限の VPCE（ssm 系 + logs/kms）
- **TGW**: VGW・Network・Prod・Dev の 4 アタッチメント。ルートテーブルは 3 枚（VGW 用 / Network→Spoke 用 / Spoke→Network 用）
- **DNS**: Prod と Dev に PHZ を作成し RAM 共有。Resolver In/Out でオンプレと疎通
- **ALB（Internal）+ ECS**: ユーザ拠点 CIDR で ALB を制限、WAF 有効
- **RDS**: 論理ダンプを ECS タスク or Systems Manager Run Command で取得 → S3
- **Transfer Family（VPC Hosted）**: オンプレのバックアップサーバに転送
- **ログ**: VPC / TGW / ALB / WAF / Trail を Security アカウント S3（KMS）へ集約

