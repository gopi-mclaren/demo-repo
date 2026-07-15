# Illustrative deployment configuration for the qa environment.
#
# References the shared formation for network and registry resources.
# Not intended to be run directly — see formations/aws/main.tf for the
# same caveat.

terraform {
  required_version = ">= 1.6.0"
}

variable "service_versions" {
  description = "Map of service name to the image tag currently deployed in qa"
  type        = map(string)
  default = {
    enrollment     = "qa-latest"
    filemanagement = "qa-latest"
    reporting      = "qa-latest"
  }
}

# One illustrated service definition per microservice. In a real
# environment this would reference the digest recorded in
# manifests/qa.yaml for that service.
resource "aws_ecs_service" "service" {
  for_each = var.service_versions

  name            = "${each.key}-qa"
  cluster         = "demo-repo-qa-cluster"
  task_definition = "${each.key}-qa:${each.value}"
  desired_count   = 1
  launch_type     = "FARGATE"
}
