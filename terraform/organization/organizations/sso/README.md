# sso

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
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssoadmin_account_assignment.admin_assign](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_managed_policy_attachment.admin_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_instances.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |
| [terraform_remote_state.org](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | n/a | `string` | n/a | yes |
| <a name="input_assigned_accounts"></a> [assigned\_accounts](#input\_assigned\_accounts) | 管理権限セットを付与する論理アカウント名（例: dev, network, security） | `set(string)` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | metadata | `string` | n/a | yes |
| <a name="input_org_state_bucket"></a> [org\_state\_bucket](#input\_org\_state\_bucket) | Organizationのtfstateが保存されているバケット名 | `string` | n/a | yes |
| <a name="input_org_state_key"></a> [org\_state\_key](#input\_org\_state\_key) | Organizationのtfstateが保存されているバケットのキー | `string` | n/a | yes |
| <a name="input_org_state_region"></a> [org\_state\_region](#input\_org\_state\_region) | Organizationのtfstateが保存されているリージョン | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | 共通タグ（モジュールに渡す tags で利用） | `map(string)` | `{}` | no |
| <a name="input_user_id"></a> [user\_id](#input\_user\_id) | Identity Center ユーザーID | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
