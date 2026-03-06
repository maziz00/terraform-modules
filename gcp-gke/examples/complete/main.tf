# Example: Production GKE Private Cluster
# Workload Identity, shielded nodes, mixed node pools

provider "google" {
  project = "my-project-id"
  region  = "me-west1"
}

module "vpc" {
  source = "../../../gcp-vpc"

  project_id = "my-project-id"
  name       = "gke-prod"

  subnets = {
    "gke-prod-subnet" = {
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
  }
}

module "gke" {
  source = "../../"

  project_id   = "my-project-id"
  region       = "me-west1"
  cluster_name = "production"

  network    = module.vpc.network_name
  subnetwork = "gke-prod-subnet"

  pods_range_name     = "pods"
  services_range_name = "services"

  kubernetes_version  = "1.29"
  enable_private_nodes    = true
  enable_private_endpoint = false # Allow external kubectl — set true for full lockdown

  master_authorized_networks = [
    {
      cidr_block   = "10.0.0.0/8"
      display_name = "Internal VPN"
    }
  ]

  enable_workload_identity      = true
  enable_binary_authorization   = true
  enable_shielded_nodes         = true
  release_channel               = "REGULAR"

  node_pools = {
    system = {
      machine_type  = "e2-standard-4"
      min_count     = 1
      max_count     = 5
      initial_count = 2
      disk_size_gb  = 100
      disk_type     = "pd-ssd"
      labels = {
        workload-type = "system"
      }
    }

    spot-apps = {
      machine_type  = "e2-standard-4"
      min_count     = 0
      max_count     = 20
      initial_count = 2
      spot          = true
      labels = {
        workload-type = "application"
      }
      taints = [{
        key    = "spot"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]
    }
  }

  labels = {
    environment = "production"
    managed-by  = "terraform"
  }

  depends_on = [module.vpc]
}

output "cluster_endpoint" {
  value = module.gke.cluster_endpoint
}

output "cluster_name" {
  value = module.gke.cluster_name
}
