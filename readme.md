# Minimal Gov Terraform Architecture Guide

This repository is a personal portfolio project that demonstrates a minimal, security-focused AWS environment built with Terraform. It is designed for government-style deployments and showcases how to structure multiple accounts, network connectivity and operations tooling in a compact setup.

## Features

- Multi-account layout (Security / Network / Prod & Dev)
- Transit Gateway hub and site-to-site VPN for hybrid connectivity
- Private DNS with Route53 and Resolver endpoints
- Strict access via ALB + WAF and SSM-based operations
- Modular Terraform code with minimal examples for quick reuse

## Repository Structure

```
.
├── infra
│   ├── modules       # Reusable Terraform modules
│   └── live          # Sample environment definitions
├── examples          # Minimal example configurations per module
├── image             # Architecture diagrams
└── readme.md         # This file
```

## Architecture

![Architecture Diagram](./image/アーキテクチャ図.png)
![Organization Diagram](./image/Organization.png)

### Account Roles

- **Security** – Collects logs and hosts security services
- **Network** – Shared VPCs, Transit Gateway and VPN gateways
- **Prod / Dev** – Application workloads such as ECS and RDS

## Quick Start

Each module under `infra/modules` is self-contained. The `examples` directory shows how to compose them.

```bash
cd examples/vpc-spoke-minimal
terraform init
terraform apply
```

## Modules Overview

Included modules cover common building blocks:

- `vpc-spoke`, `tgw-hub` and related attachments
- `ecs-alb-service` for container workloads
- `rds` for Aurora Serverless v2 databases
- `waf-acl`, `observability-baseline`, `db-dump-to-s3` and more

Refer to the `examples` folder for full usage patterns.

## Author

Created by the repository owner as part of a personal job-hunting portfolio.

