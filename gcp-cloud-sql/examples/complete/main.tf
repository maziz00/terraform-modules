# Example: Production Cloud SQL PostgreSQL
# Private IP, HA, automated backups, read replica

provider "google" {
  project = "my-project-id"
  region  = "me-west1"
}

module "vpc" {
  source = "../../../gcp-vpc"

  project_id = "my-project-id"
  name       = "sql-prod"

  subnets = {
    "sql-prod-subnet" = {
      region        = "me-west1"
      ip_cidr_range = "10.0.0.0/24"
    }
  }
}

module "postgres" {
  source = "../../"

  project_id       = "my-project-id"
  region           = "me-west1"
  name             = "app-db"
  database_version = "POSTGRES_15"

  tier         = "db-custom-4-16384" # 4 vCPU, 16 GB RAM
  disk_size_gb = 100
  network      = module.vpc.network_self_link

  # HA — automatic failover to standby in another zone
  availability_type = "REGIONAL"

  # Backups
  backup_enabled         = true
  backup_start_time      = "02:00"
  backup_retained_count  = 14
  point_in_time_recovery = true

  # Maintenance window — Sunday 3 AM UTC
  maintenance_window_day  = 7
  maintenance_window_hour = 3

  # Prevent accidental deletion
  deletion_protection = true

  # Create application databases
  databases = ["app_production", "app_analytics"]

  # One read replica for analytics queries
  read_replicas = 1

  # PostgreSQL performance tuning
  database_flags = {
    "max_connections"       = "200"
    "shared_buffers"        = "4096MB"
    "work_mem"              = "64MB"
    "log_min_duration_statement" = "1000" # Log queries slower than 1s
  }

  labels = {
    environment = "production"
    app         = "backend"
    managed-by  = "terraform"
  }

  depends_on = [module.vpc]
}

output "instance_connection_name" {
  value = module.postgres.instance_connection_name
}

output "private_ip" {
  value = module.postgres.private_ip_address
}
