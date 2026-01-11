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
-

## Issues
-
-
-

## Future Updates
-
-
-


## Notes and Documentation

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