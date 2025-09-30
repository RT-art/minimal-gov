# ssouser

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.3, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.14.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_identitystore_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_user) | resource |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | Identity Centerを有効化しているリージョン | `string` | `"ap-northeast-1"` | no |
| <a name="input_user"></a> [user](#input\_user) | 作成するIdentity Centerユーザー属性 | <pre>object({<br>    user_name    = string           # 一意なユーザー名（例: taro.portfolio）<br>    given_name   = string           # 名<br>    family_name  = string           # 姓<br>    display_name = string           # 表示名<br>    email        = string           # メールアドレス（招待/通知に使用）<br>    phone        = optional(string) # 省略可<br>  })</pre> | <pre>{<br>  "display_name": "Taro Yamada",<br>  "email": "taro@example.com",<br>  "family_name": "Yamada",<br>  "given_name": "Taro",<br>  "user_name": "taro.portfolio"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_identity_store_id"></a> [identity\_store\_id](#output\_identity\_store\_id) | n/a |
| <a name="output_user_id"></a> [user\_id](#output\_user\_id) | n/a |
<!-- END_TF_DOCS -->
