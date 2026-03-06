# Example: Complete GCP VPC
# VPC with subnets, secondary ranges for GKE, Cloud NAT, firewall rules

provider "google" {
  project = "my-project-id"
  region  = "me-west1"
}

module "vpc" {
  source = "../../"

  project_id = "my-project-id"
  name       = "production"

  subnets = {
    "prod-gke" = {
      region        = "me-west1"
      ip_cidr_range = "10.0.0.0/20"
      secondary_ranges = [
        {
          range_name    = "pods"
          ip_cidr_range = "10.4.0.0/14"
        },
        {
          range_name    = "services"
          ip_cidr_range = "10.8.0.0/20"
        }
      ]
    }
    "prod-apps" = {
      region        = "me-west1"
      ip_cidr_range = "10.1.0.0/20"
    }
    "prod-data" = {
      region        = "me-west1"
      ip_cidr_range = "10.2.0.0/20"
    }
  }

  enable_cloud_nat = true
  enable_flow_logs = true

  firewall_rules = {
    allow-internal = {
      direction = "INGRESS"
      priority  = 1000
      ranges    = ["10.0.0.0/8"]
      allow = [{
        protocol = "all"
      }]
    }
    allow-iap-ssh = {
      direction = "INGRESS"
      priority  = 1000
      ranges    = ["35.235.240.0/20"] # IAP range
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
      target_tags = ["allow-iap"]
    }
    allow-health-checks = {
      direction = "INGRESS"
      priority  = 1000
      ranges    = ["130.211.0.0/22", "35.191.0.0/16"] # GCP health check ranges
      allow = [{
        protocol = "tcp"
      }]
      target_tags = ["allow-health-check"]
    }
  }
}

output "network_name" {
  value = module.vpc.network_name
}

output "subnets" {
  value = module.vpc.subnets
}
