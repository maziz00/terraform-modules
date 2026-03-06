# Example: ECR Repositories with Lifecycle Policies
# Immutable tags, scan on push, automatic cleanup

provider "aws" {
  region = "me-south-1"
}

module "ecr" {
  source = "../../"

  repositories = {
    "api-service" = {
      image_tag_mutability = "IMMUTABLE"
      scan_on_push         = true
    }
    "web-frontend" = {
      image_tag_mutability = "IMMUTABLE"
      scan_on_push         = true
    }
    "worker" = {
      image_tag_mutability = "IMMUTABLE"
      scan_on_push         = true
    }
  }

  lifecycle_policy_max_images    = 30 # Keep last 30 untagged
  lifecycle_policy_tagged_count  = 50 # Keep last 50 tagged

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

output "repository_urls" {
  value = module.ecr.repository_urls
}
