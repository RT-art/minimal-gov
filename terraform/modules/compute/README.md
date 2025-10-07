# Compute Modules

アプリケーションワークロード向けの計算リソースを作成するモジュールをまとめています。

- `ec2_bastion`: Systems Manager 経由で運用する踏み台 EC2 を作成し、IAM ロールとセキュリティグループを付与します。
- `ecr`: コンテナイメージを格納する ECR リポジトリを作成し、ライフサイクルポリシーやアクセス制御を設定します。
- `ecs_fargate`: Fargate ベースの ECS クラスターとサービスを構築し、ALB 連携や CloudWatch Logs 連携を含めてデプロイを自動化します。
