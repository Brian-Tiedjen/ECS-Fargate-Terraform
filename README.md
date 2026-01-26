# ECS-Fargate-Terraform

## Architecture summary

Public ALB → ECS Fargate (private subnets) → VPC endpoints (ECR/Logs/STS) + S3 gateway endpoint

- This architecture implements a fault-tolerant, scalable web tier using native AWS patterns.

## Network flow (at a glance)

```text
Internet users
     |
     v
Public ALB (public subnets)
     |
     v
ECS tasks (private subnets, no public IPs)
  +--> VPC endpoints: ECR API/DKR, Logs, STS (HTTPS)
  +--> S3 gateway endpoint (ECR layers / S3 access)
  +--> DNS + task metadata (inside VPC)
  x--> No outbound internet path (no NAT)
```

## Network write-up

Requests enter through the public ALB, which is the only internet-facing component. The ALB forwards traffic to ECS tasks running in private subnets with no public IPs. Those tasks cannot reach the public internet because their security group egress is restricted to VPC interface endpoints, the S3 gateway endpoint, DNS within the VPC, and the ECS task metadata endpoint. This keeps the data plane private while still allowing ECS to pull images from ECR, emit logs to CloudWatch, and use STS without any outbound internet path.

## What This Project Demonstrates

This project provisions a production-style AWS network and container stack using Terraform, with an emphasis on scalability, isolation, and observability.

Key capabilities include:
- Multi-AZ VPC with public and private subnets
- Internet Gateway for public subnets
- Public Application Load Balancer spanning multiple AZs
- ECS Fargate service in private subnets behind the ALB
- ECS task egress via VPC endpoints (no outbound internet)
- ECR repository with immutable tags, scan on push, and lifecycle cleanup
- Security group isolation between ALB and ECS tiers
- Deployment circuit breaker for safe rollbacks
- IAM task execution role and task role (least-privilege intent)
- Remote Terraform state stored in S3 (configured in CI)
- ECS service autoscaling (target tracking for CPU and memory)
- ECS cluster container insights enabled
- Runtime hardening (non-root user, healthcheck, read-only root filesystem)
- Monitoring/alerting: ALB 5xx/unhealthy + ECS CPU/memory alarms, SNS notifications, optional dashboard
- CI/CD integration with GitHub Actions (plan/apply/build/push/deploy)
- GitHub Environments required reviewer gates (configured in GitHub UI settings)
- Policy-as-code checks in CI via Conftest (OPA)
- Static IaC checks in CI with TFLint and Checkov
- Module-based infrastructure design

Centralized logging:
- ALB access logs (S3)
- VPC Flow Logs (reject only)
- CloudTrail (multi-region, log file validation, S3 + SNS topic for notifications)
- CloudWatch Logs for app and VPC flow logs
- Logs bucket hardening (encryption, versioning, ownership controls, public access block, lifecycle policy)

## Module Versions

- Terraform version: ~> 1.14.0
- AWS provider version: ~> 6.27.0
- random provider version: ~> 3.5.1

## Deployment Notes

Environment-specific deployment steps live under `infra/envs/{dev,stage,prod}`.
Backend config (S3 bucket/key/region) is injected via CI during `terraform init`.
Note: ALB deletion protection is disabled to allow clean teardown.  
Note: The logs S3 bucket uses `force_destroy = true` for demo convenience.
Note: CloudWatch log retention is set to 90 days for demo convenience.
Note: ECR repositories use `force_delete = true` to allow clean teardown in demos.


## Outputs

- ALB URL: `alb_url`
- ALB DNS name: `alb_dns_name`
- ECR repository URL: `ecr_repository_url`
- Stage/Prod ALB URLs: available via the same output names in `infra/envs/stage` and `infra/envs/prod`

## App endpoints

- `/` returns the current app version.
- `/version` returns the current app version (explicit endpoint for demos).
- `/health` returns a basic health status.


## Costs (Estimated)

Costs are intentionally left as TBD.
This project is designed for short-lived demo deployments and learning purposes, not long-running production workloads.

Primary cost drivers:
- Application Load Balancer
- VPC interface endpoints
- Fargate tasks
- CloudWatch logs and alarms
- S3 storage

## Assumptions & Tradeoffs

- Single region deployment
- Environments are isolated per VPC and state (dev/stage/prod use separate backends)
- Logs bucket uses `force_destroy` and short retention for demo convenience
- Health checks use `GET /health` on the app
- ECS tasks use endpoint-only egress (no outbound internet)

## Security Considerations

- ECS tasks are deployed exclusively in private subnets
- No inbound internet access to compute resources
- ALB is the only public-facing component
- Security groups restrict ECS ingress to ALB only; ECS egress is limited to VPC endpoints, S3 gateway, DNS, and task metadata
- IAM roles scoped to ECS execution + app needs only
- VPC Flow Logs capture rejected traffic for analysis
- Default VPC security group is locked down
- ALB drops invalid headers

## CI/CD Workflow

- Dev plan runs on push to `main` and via `workflow_dispatch`
- Staging/Prod pipelines run via `workflow_dispatch`
- Drift detection runs on a schedule and via `workflow_dispatch`
- Policy checks run on every plan using Conftest against the Terraform plan JSON
- Static checks run on every plan using TFLint and Checkov
- Dev: plan only (no apply)
- Staging: plan + apply, then build/push and deploy
- Prod: plan + apply, then build/push and deploy
- Staging teardown runs as a separate workflow after a successful prod deployment, and can also be triggered manually
- Scheduled drift detection runs and opens an issue if drift is detected
- Terraform state stored remotely in S3; backend config is passed via `terraform init` in CI
- Apply and deploy require GitHub environment approvals
- CI includes an ECR bootstrap check: if the repo exists but is not in state, it is imported; if it does not exist, Terraform creates it on apply
- Staging and production teardown workflows are separate and isolated

## CI/CD Timings (Most Recent)

- Dev (plan only): 53s
- Staging build (full pipeline): 5m 7s
- Prod build (full pipeline): 5m 9s
- Teardown staging: 3m 8s
- Teardown prod: 4m 8s

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
