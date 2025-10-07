# Organization

`terraform/organization` ディレクトリは、AWS Organizations と IAM Identity Center の初期セットアップを Terraform で自動化するための設定をまとめています。リモートステートの基盤を先に構築し、続いて組織構成を適用することで、組織横断のガバナンスをコードで管理できます。

## ディレクトリ構成
- `organizations/`: AWS Organizations・OU・メンバーアカウント・SCP を定義するモジュール群を呼び出します。`policies/` には追加 SCP、`sso/` には IAM Identity Center 用の定義を配置しています。

- `state_backend/`: S3 バケットを作成し、Terraform リモートステートを保護します。`terraform.tfvars.sample` を複製して環境名や利用アカウントを設定してから適用します。


## 運用フロー
1. `state_backend/terraform.tfvars.sample` をコピーして値を調整し、実行してバックエンドを用意します。
2. `organizations/terraform.tfvars.sample` を参考に `terraform.tfvars` に作成し、OU 構成・メンバーアカウント情報・`add_scps` の割り当てを更新します。
3. `plan` / `apply` で組織全体の設定を反映します。`policies/` 配下の JSON を追加するとカスタム SCP を適用できます。
4. SSOディレクトリで、新たに作成したアカウントを追記すれば、SSOユーザが作成されます(Administratorアクセスを与えています。)

## 参考
- https://qiita.com/rt-art/items/c54d0cea114c0ee72122
- https://qiita.com/rt-art/items/c6364d90b1546e92db57
