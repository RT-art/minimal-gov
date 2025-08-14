terraform {
  backend "s3" {
    # backend.tf には変数が使えないため、以下の値を環境に合わせて手動で設定してください。
    # AWSアカウントIDは `aws sts get-caller-identity --query Account --output text` コマンドで確認できます。
    bucket         = "rensyu-app-tfstate-ap-northeast-1-[YOUR_AWS_ACCOUNT_ID]"
    key            = "rensyuEC2/ap-northeast-1/dev/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "rensyu-app-tf-locks"
    encrypt        = true
  }
}
