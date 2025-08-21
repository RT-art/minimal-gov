# Terraform Remote Backend

## 概要


* 追加リソース: DynamoDB は不要
https://developer.hashicorp.com/terraform/language/backend/s3
* `terraform-aws-modules/s3-bucket` を利用

## ディレクトリ

```
modules/platform/remote-backend/
   local.tf  main.tf  outputs.tf  variable.tf
stacks/remote-backend/ap-northeast-1/dev/
   backend.tf  backend.hcl.example  provider.tf  variable.tf
   main.tf  outputs.tf  terraform.tfvars.example
```

## バケットのセキュリティ既定値

* Versioning 有効
* 暗号化: 既定 AES256（必要に応じて KMS へ切替可）
* Public Access Block 全面有効
* Object Ownership: `BucketOwnerEnforced`（ACL 無効）
* バケットポリシー: 最新 TLS 強制 / 平文アップロード拒否 / HTTP 拒否
* ライフサイクル: 旧バージョンを `lifecycle_days` で削除（既定 180 日）

## 事前条件

* Terraform **1.11 以上**（S3 ネイティブ・ロック使用時）
* AWS 認証情報（環境変数やプロファイルなど）

## 使い方（Quick Start）

1. 変数ファイルを用意

   ```bash
   cd stacks/remote-backend/ap-northeast-1/dev
   cp terraform.tfvars.example terraform.tfvars
   # 必要に応じて env/app_name/region/tags など編集
   ```
2. バケットを作成（初回はローカルステートのまま）

   ```bash
   terraform init
   terraform apply -auto-approve
   ```
3. 作成されたバケット名を取得

   ```bash
   terraform output -raw tfstate_bucket_name
   ```
4. `backend.hcl` を作成（VCS 管理対象外）

   ```hcl
   bucket       = "<上の出力で得たバケット名>"
   key          = "states/dev/ap-northeast-1/terraform.tfstate"
   region       = "ap-northeast-1"
   encrypt      = true
   use_lockfile = true   # S3 ネイティブ・ロック
   ```
5. リモートバックエンドへ移行

   ```bash
   terraform init -reconfigure \
     -backend-config=backend.hcl \
     -migrate-state
   ```

> 参考: `backend.tf` は `backend "s3" {}` の空定義にしておき、詳細は `backend.hcl` に記載します。

## モジュール入力

| 変数                   | 型           |      既定 | 説明                                |
| -------------------- | ----------- | ------: | --------------------------------- |
| `env`                | string      |         | 環境名（`dev`/`stg`/`prod`/`sandbox`） |
| `app_name`           | string      |         | アプリ名（バケット名に使用）                    |
| `region`             | string      |         | バケットリージョン                         |
| `tags`               | map(string) |    `{}` | provider の `default_tags` に上乗せ    |
| `versioning_enabled` | bool        |  `true` | バージョニング有効化                        |
| `use_kms`            | bool        | `false` | KMS で暗号化する場合は `true`              |
| `kms_master_key_id`  | string      |  `null` | KMS キー ID/ARN/alias               |
| `force_destroy`      | bool        |  `true` | バケット空でなくても削除可                     |
| `lifecycle_days`     | number      |   `180` | 旧バージョンの保持日数                       |

## 出力

* `tfstate_bucket_name` / `tfstate_bucket_arn`
