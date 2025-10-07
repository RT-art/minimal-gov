# Storage Modules

状態管理やデータベースなど、ストレージ系リソースを提供するモジュールです。

- `backend`: Terraform リモートステート用の S3 バケットとアクセスログ、暗号化、ライフサイクルを構成します。
- `rds`: Secrets Manager と合わせて高可用な RDS インスタンスをプロビジョニングします。
