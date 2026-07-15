# Illustrative deployment configuration for the dev environment.
#
# References the shared formation for network and registry resources.
# Not intended to be run directly — see formations/aws/main.tf for the
# same caveat.

terraform {
  required_version = ">= 1.6.0"
}

variable "service_versions" {
  description = "Map of service name to the image tag currently deployed in dev"
  type        = map(string)
  default = {
    enrollment     = "dev-latest"
    filemanagement = "dev-latest"
    reporting      = "dev-latest"
  }
}

# One illustrated service definition per microservice. In a real
# environment this would reference the digest recorded in
# manifests/dev.yaml for that service.
resource "aws_ecs_service" "service" {
  for_each = var.service_versions

  name            = "${each.key}-dev"
  cluster         = "demo-repo-dev-cluster"
  task_definition = "${each.key}-dev:${each.value}"
  desired_count   = 1
  launch_type     = "FARGATE"
}
