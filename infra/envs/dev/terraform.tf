#terraform settings block
terraform {
  required_version = ">= 1.14.3"

    backend "s3" {  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.27.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"

    }
  }
}


#provider block and default tags
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = var.environment
      Project     = "Terraform-ECS-Service"
      terraform   = "true"
    }

  }
}
