# organizations

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.3, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.14 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_organizations"></a> [organizations](#module\_organizations) | ../../modules/grobal/organizations | n/a |
| <a name="module_scp"></a> [scp](#module\_scp) | ../../modules/grobal/scp | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_ous"></a> [additional\_ous](#input\_additional\_ous) | 追加で作成したいOUのマップ。keyがOU名、valueが親OU名 | <pre>map(object({<br>    parent_ou = string # 親OU名。指定されなければrootにぶら下げる<br>  }))</pre> | `{}` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | n/a | `string` | n/a | yes |
| <a name="input_aws_service_access_principals"></a> [aws\_service\_access\_principals](#input\_aws\_service\_access\_principals) | サービスアクセスを有効化するリソース指定（guardduty,configなど、組織内で一元管理したいリソース） | `list(string)` | <pre>[<br>  "guardduty.amazonaws.com",<br>  "config.amazonaws.com",<br>  "cloudtrail.amazonaws.com",<br>  "securityhub.amazonaws.com"<br>]</pre> | no |
| <a name="input_delegated_services"></a> [delegated\_services](#input\_delegated\_services) | Securityアカウントを委任管理者に登録するサービス | `set(string)` | n/a | yes |
| <a name="input_enabled_policy_types"></a> [enabled\_policy\_types](#input\_enabled\_policy\_types) | なんのポリシー(scp、tagポリシー等)を有効化するか | `list(string)` | <pre>[<br>  "SERVICE_CONTROL_POLICY",<br>  "TAG_POLICY"<br>]</pre> | no |
| <a name="input_env"></a> [env](#input\_env) | Metadata | `string` | n/a | yes |
| <a name="input_member_accounts"></a> [member\_accounts](#input\_member\_accounts) | メンバーアカウント作成 | <pre>map(object({<br>    name  = string<br>    email = string<br>    ou    = string<br>    tags  = string<br>  }))</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_security_account_email"></a> [security\_account\_email](#input\_security\_account\_email) | n/a | `string` | n/a | yes |
| <a name="input_security_account_name"></a> [security\_account\_name](#input\_security\_account\_name) | Securityアカウント作成 | `string` | `"Security"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_member_account_ids"></a> [member\_account\_ids](#output\_member\_account\_ids) | メンバーアカウントの ID マップ (key: 論理名, value: Account ID) |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | AWS Organization の ID |
| <a name="output_ou_ids"></a> [ou\_ids](#output\_ou\_ids) | 主要 OU と追加 OU の ID マップ |
| <a name="output_root_id"></a> [root\_id](#output\_root\_id) | Organization ルート（Root）の ID |
| <a name="output_security_account_id"></a> [security\_account\_id](#output\_security\_account\_id) | Security アカウントの AWS Account ID |
<!-- END_TF_DOCS -->
