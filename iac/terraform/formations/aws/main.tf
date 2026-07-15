# Illustrative infrastructure formation for the demo-repo microservices.
#
# This file exists to show the shape of the shared infrastructure that
# would sit behind the branching, tagging, and promotion strategy in this
# repository. It is not connected to a real AWS account, has no backend
# configured for remote state, and is not intended to be run with
# `terraform plan` or `terraform apply` as-is.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region this formation is illustrated in"
  type        = string
  default     = "us-east-1"
}

# One container registry per microservice, mapping 1:1 with the folders
# under components/. Image tag immutability is what backs the "never
# rebuilt after the release cut" guarantee described in the strategy.
resource "aws_ecr_repository" "service" {
  for_each = toset([
    "enrollment",
    "filemanagement",
    "reporting",
  ])

  name                 = "demo-repo/${each.key}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Minimal shared network placeholder for the illustrated environments.
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "demo-repo-vpc"
  }
}
