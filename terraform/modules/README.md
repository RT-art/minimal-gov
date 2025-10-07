# Terraform Modules

複数環境で共有する再利用可能な Terraform モジュールを分類し、用途ごとに整理しています。

- `compute/`: EC2 や ECS、ECR など計算リソースを提供するモジュール群。
- `grobal/`: Organizationや oidcなど、アカウント横断で利用する基盤モジュール。
- `network/`: VPC・ALB・Transit Gateway などネットワーク構成を担うモジュール。
- `storage/`: S3 バックエンドや RDS などのストレージ／データベースを扱うモジュール。
