# central-security (Security account)

セキュリティアカウント（委任管理者）で以下を構成するモジュール：

- **GuardDuty**: 検出器、組織設定（自動有効化/機能ON）
- **Security Hub**: Central Configuration を有効化、任意でスタンダード購読、所見集約
- **AWS Config**: 組織アグリゲータ
- **CloudTrail**: 組織トレイル + S3/KMS（最小ポリシー）

> 事前条件
>
> - 管理アカウント側で各サービスの *サービス固有の委任管理者* を登録済みであること（GuardDuty/Security Hub/CloudTrail）。
>
> 使い方（例）
>
> ```hcl
> provider "aws" {
>   alias  = "security"
>   region = "ap-northeast-1"
>   assume_role {
>     role_arn = "arn:aws:iam::<SECURITY_ACCOUNT_ID>:role/OrganizationAccountAccessRole"
>   }
> }
>
> module "central_security" {
>   source = "../modules/central-security"
>   providers = { aws = aws.security }
>
>   tags = {
>     Project = "minimal-gov"
>   }
>
  tags = {
    Project = "minimal-gov"
  }

}
> ```
>
> ※ Security Hub のスタンダードやコントロールを OU/アカウント単位で一元管理したい場合は、Central Config + **Configuration Policy** の適用（別途）を推奨。
