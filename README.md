# ECS-Fargate-Terraform
This project demonstrates a production-style, serverless container platform on AWS using ECS with Fargate, built and managed entirely with Terraform.

The goal is to show how to deploy and operate containerized workloads without managing servers, while following real-world patterns for networking, security, observability, and deployment safety.

The architecture separates public ingress from private compute, uses immutable container images, and applies least-privilege IAM throughout.

# Key Design Goals
- Serverless compute using ECS Fargate
- Private application workloads behind a public ALB
- Immutable deployments using versioned container images
- Least-privilege IAM with task-level permissions
- Health-check-driven deployments and rollbacks
- Production-style networking boundaries
- Declarative infrastructure with Terraform
- Basic FastAPI app container (/, /health) to validate ALB routing

## What it provisions today
- VPC with public/private subnets, IGW, NAT gateway, route tables, and associations
- Security groups for ALB and ECS service 
- Public Application Load Balancer, target group, HTTP listener, and health checks
- CloudWatch alarms for ALB 5xx and unhealthy hosts
- CloudWatch Log Group for app logs
- VPC Flow Logs (REJECT only) with IAM role
- CloudTrail to S3
- S3 log bucket with versioning, lifecycle, SSE, and public access blocked
- ALB access logs delivered to the S3 log bucket
- ECR repository for app images (scan on push)
- IAM task execution role and task role
- ECS cluster, task definition, and Fargate service in private subnets (no public IP), registered to the ALB


## Issues
-
-
-

## Future Updates
- Build/push the container image into ECR
- HTTPS/TLS termination and certificates on the ALB
- Autoscaling policies for the ECS service
- CI/CD pipeline or release automation


## Notes and Documentation
- The log bucket uses `force_destroy = true` for demo purposes

# Reused Terraform modules

These modules were copied from `Terraform_modules/Terraform-WebServer/modules`:
- `infra/modules/vpc`
- `infra/modules/alb` (tweaked for ECS)
- `infra/modules/logs`
- `infra/modules/security` (tweaked for ECS tasks)


# Resources used
https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_repository
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_container_definition
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_service#deployment_circuit_breaker-block