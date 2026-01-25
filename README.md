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
- ECS service autoscaling (target tracking for CPU and memory)
- ECS cluster container insights enabled
- Container image hardening (non-root user + healthcheck)
- Structured monitoring/alerting beyond basic ALB alarms
- CI/CD integration with GitHub Actions (plan/apply/build/push/deploy)
- GitHub Environments required reviewer gates (configured in GitHub UI settings)
- Policy-as-code checks in CI via Conftest (OPA)
- Static IaC checks in CI with TFLint and Checkov
- Module-based infrastructure design

Centralized logging:
- ALB access logs (S3)
- VPC Flow Logs (reject only)
- CloudTrail (S3 + SNS notifications)
- CloudWatch Logs for app and VPC flow logs

## Module Versions

- Terraform version: 1.14.3
- AWS provider version: 6.27.0
- random provider version: 3.5.1

## Deployment Notes

Environment-specific deployment steps live under `infra/envs/{dev,stage,prod}`.
Note: ALB deletion protection is disabled to allow clean teardown.  
Note: The logs S3 bucket uses `force_destroy = true` for demo convenience.
Note: CloudWatch log retention is set to 90 days for demo convenience.
Note: ECR repositories use `force_delete = true` to allow clean teardown in demos.


## Outputs

- ALB URL: `alb_url`
- ALB DNS name: `alb_dns_name`
- ECR repository URL: `ecr_repository_url`
- Stage/Prod ALB URLs: available via the same output names in `infra/envs/stage` and `infra/envs/prod`


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
- Environments are isolated per VPC and state (dev/stage/prod use separate backends)
- Logs bucket uses `force_destroy` and short retention for demo convenience
- Health checks use `GET /health` on the app

## Security Considerations

- ECS tasks are deployed exclusively in private subnets
- No inbound internet access to compute resources
- ALB is the only public-facing component
- Security groups enforce ALB → ECS traffic only
- IAM roles scoped to ECS execution + app needs only
- VPC Flow Logs capture rejected traffic for analysis
- Default VPC security group is locked down
- ALB drops invalid headers

## CI/CD Workflow

- Workflows are run manually via `workflow_dispatch` for now
- Policy checks run on every plan using Conftest against the Terraform plan JSON
- Static checks run on every plan using TFLint and Checkov
- Dev: plan only (no apply)
- Staging: plan + apply, then build/push and deploy
- Prod: plan + apply, then build/push and deploy
- Staging teardown runs as a separate workflow only after a successful prod deployment
- Scheduled drift detection runs and opens an issue if drift is detected
- Terraform state stored remotely in S3; backend config is passed via `terraform init` in CI
- Apply and deploy require GitHub environment approvals
- CI includes an ECR bootstrap check: if the repo exists but is not in state, it is imported; if it does not exist, Terraform creates it on apply
- Staging and production teardown workflows are separate and isolated

## Screenshots
- Staging plan waiting for required reviewer approval in the CI pipeline
  <img width="701" height="232" alt="image" src="https://github.com/user-attachments/assets/e407871c-1751-4cc1-89e3-f71923c2367a" />

- Prod plan waiting for required reviewer approval in the CI pipeline
  <img width="701" height="232" alt="image" src="https://github.com/user-attachments/assets/a823e591-2de8-4517-a974-76d2478e4035" />

These gates pause Terraform apply and ECS deployment until a human approves the environment.



## Why Modules?

The goals of modularization are to:
- Establish clear boundaries between infrastructure concerns (networking, load balancing, logging, IAM, compute)
- Make dependencies explicit through well-defined inputs and outputs
- Improve readability and long-term maintainability

## Notes

- This is a personal learning and portfolio project.
- Resources are created for demonstration purposes only.
- Not intended for production or sensitive workloads.

## Future Updates
- GitHub Actions OIDC auth.
- AWS Budgets + alert.
- CloudWatch log metric filters + alarms.
- Terraform‑docs + pre‑commit.


## Resources used

https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html  
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition  
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_repository  
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_container_definition  
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_service#deployment_circuit_breaker-block
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy
https://terrateam.io/blog/terraform-drift-detection-github-actions
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target
https://cicube.io/workflow-hub/ad-m-github-push-action/
