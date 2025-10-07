# Global Modules

組織全体で共通利用する ID やガバナンス関連のモジュールを配置しています。

- `oidc`: GitHub Actions 用の OIDC プロバイダーとロールを作成し、指定ポリシーを付与します。
- `organizations`: AWS Organizations の OU 構成やメンバーアカウント、委任管理者をコード化します。
- `scp`: Service Control Policy を管理し、組織アカウントへの適用を自動化します。
