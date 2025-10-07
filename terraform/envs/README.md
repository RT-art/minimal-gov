# Environment Configuration

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.11.3, < 2.0.0 |
| aws | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| alb_waf | ../modules/network/alb_waf | n/a |
| ec2_bastion | ../modules/compute/ec2_bastion | n/a |
| ecr | ../modules/compute/ecr | n/a |
| ecs_fargate | ../modules/compute/ecs_fargate | n/a |
| endpoint | ../modules/network/endpoint | n/a |
| rds | ../modules/storage/rds | n/a |
| route53_private_zone | ../modules/network/route53_private_zone | n/a |
| tgw_hub | ../modules/network/tgw_hub | n/a |
| tgw_route | ../modules/network/tgw_route | n/a |
| tgw_vpc_attachment | ../modules/network/tgw_vpc_attachment | n/a |
| vpc | ../modules/network/vpc | n/a |
| vpc_route_to_tgw | ../modules/network/vpc_route_to_tgw | n/a |

