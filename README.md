# ECS-Fargate-Terraform

## Architecture summary

Public ALB → ECS Fargate (private subnets) → NAT Gateway → Internet Gateway

- This architecture implements a fault-tolerant, scalable web tier using native AWS patterns.

## What This Project Demonstrates

This project provisions a production-style AWS network and container stack using Terraform, with an emphasis on scalability, isolation, and observability.

Key capabilities include:
- Multi-AZ VPC with public and private subnets
- Internet Gateway with single NAT Gateway (cost-aware design)
- Public Application Load Balancer spanning multiple AZs
- ECS Fargate service in private subnets behind the ALB
- Task definition with immutable image tags
- Security group isolation between ALB and ECS tiers
- Deployment circuit breaker for safe rollbacks
- IAM task execution role and task role (least-privilege intent)
- Remote Terraform state stored in S3 (configured in CI)
- CI/CD integration with GitHub Actions (plan/apply/build/push/deploy)
- Module-based infrastructure design

Centralized logging:
- ALB access logs (S3)
- VPC Flow Logs (reject only)
- CloudTrail (S3)
- CloudWatch Logs for app and VPC flow logs

## Module Versions

- Terraform version: 1.14.3
- AWS provider version: 6.27.0
- random provider version: 3.5.1

## Deployment Notes

- Environment-specific deployment steps will be documented as staging and prod workflows mature.
Note: ALB deletion protection is disabled to allow clean teardown.  
Note: The logs S3 bucket uses `force_destroy = true` for demo convenience.

## Environment Structure

- `infra/envs/dev`
- `infra/envs/stage`
- `infra/envs/prod`

## Outputs

- ALB URL: `alb_url`
- ALB DNS name: `alb_dns_name`
- ECR repository URL: `ecr_repository_url`
- ECS cluster name: `ecs_cluster_name`
- ECS service name: `ecs_service_name`

## Costs (Estimated)

Costs are intentionally left as TBD.
This project is designed for short-lived demo deployments and learning purposes, not long-running production workloads.

Primary cost drivers:
- Application Load Balancer
- NAT Gateway
- Fargate tasks
- CloudWatch logs and alarms
- S3 storage

## Assumptions & Tradeoffs

- Single NAT Gateway (cost-aware, single-AZ dependency)
- Single region deployment
- Logs bucket uses `force_destroy` and short retention for demo convenience
- Health checks use `GET /` on the app

## Security Considerations

- ECS tasks are deployed exclusively in private subnets
- No inbound internet access to compute resources
- ALB is the only public-facing component
- Security groups enforce ALB → ECS traffic only
- IAM roles scoped to ECS execution + app needs only
- VPC Flow Logs capture rejected traffic for analysis

## CI/CD Workflow

- Pull Requests: `terraform init / fmt / validate / plan`
- Main branch: approved plan is applied, then image is built and pushed to ECR, then deploy runs
- Terraform state stored remotely in S3; backend config is passed via `terraform init` in CI
- Apply and deploy require GitHub environment approvals
- CI includes an ECR bootstrap check: if the repo exists but is not in state, it is imported; if it does not exist, Terraform creates it on apply

## Why Modules?

The goals of modularization are to:
- Establish clear boundaries between infrastructure concerns (networking, load balancing, logging, IAM, compute)
- Make dependencies explicit through well-defined inputs and outputs
- Improve readability and long-term maintainability

## Notes

- This is a personal learning and portfolio project.
- Resources are created for demonstration purposes only.
- Not intended for production or sensitive workloads.

## Issues/Resolved updates

- None currently.

## Future Update Ideas

- HTTPS/TLS termination and certificates on the ALB
- Autoscaling policies for the ECS service
- Structured monitoring/alerting beyond basic ALB alarms

## Resources used

https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html  
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition  
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_repository  
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_container_definition  
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_service#deployment_circuit_breaker-block
