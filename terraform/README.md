# Terraform ディレクトリ概要

- `envs`: 環境ごとのルートディレクトリ
- `modules`: 複数の環境で共有する再利用可能な Terraform モジュールを格納します。
- `organization`: 組織全体に共通するポリシーやベースライン設定をまとめます。

```
terraform
├── organization # <--- Organization entrypoint(management account)
│    ├── organizations 
│    │   ├── policies 
│    │   └── sso 
│    └── state_backend
│ 
├── envs
│   ├── dev
│   └── prod
│       ├── env.hcl
│       ├── network # <--- Network account entrypoint
│       │   ├── ec2 
│       │   ├── endpoint 
│       │   ├── tgw_attachment 
│       │   ├── tgw_hub 
│       │   ├── tgw_route 
│       │   ├── vpc 
│       │   └── vpc_route_to_tgw 
│       │ 
│       └── workloads # <--- Workload account entrypoint
│           ├── alb 
│           ├── app 
│           ├── dns 
│           ├── ecr 
│           ├── network
│           │   ├── endpoint
│           │   ├── tgw_attachment
│           │   ├── tgw_hub
│           │   ├── vpc
│           │   └── vpc_route_to_tgw
│           └── postgres 
│ 
├── modules # <--- modules
│   ├── compute 
│   │   ├── ec2_bastion 
│   │   ├── ecr 
│   │   └── ecs_fargate 
│   ├── grobal 
│   │   ├── oidc 
│   │   ├── organizations
│   │   └── scp 
│   ├── network
│   │   ├── alb_waf
│   │   ├── endpoint 
│   │   ├── route53_private_zone 
│   │   ├── tgw_hub 
│   │   ├── tgw_route 
│   │   ├── tgw_vpc_attachment 
│   │   ├── tgw_vpc_attachment_accepter
│   │   ├── vpc # VPCモジュール
│   │   └── vpc_route_to_tgw 
│   └── storage 
│       ├── backend 
│       └── rds 
│
```
