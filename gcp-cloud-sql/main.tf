# ─────────────────────────────────────────────────────
# GCP Cloud SQL Module
# Private IP, automated backups, read replicas, HA
# ─────────────────────────────────────────────────────

resource "random_id" "suffix" {
  byte_length = 4
}

# ── PRIVATE SERVICE ACCESS ───────────────────────────

resource "google_compute_global_address" "private_ip" {
  name          = "${var.name}-private-ip"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network
}

resource "google_service_networking_connection" "private" {
  network                 = var.network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip.name]
}

# ── PRIMARY INSTANCE ─────────────────────────────────

resource "google_sql_database_instance" "this" {
  name                = "${var.name}-${random_id.suffix.hex}"
  project             = var.project_id
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    disk_size         = var.disk_size_gb
    disk_autoresize   = var.disk_autoresize
    availability_type = var.availability_type

    disk_autoresize_limit = var.disk_autoresize_limit

    ip_configuration {
      ipv4_enabled    = var.enable_public_ip
      private_network = var.network

      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.value
        }
      }
    }

    backup_configuration {
      enabled                        = var.backup_enabled
      start_time                     = var.backup_start_time
      point_in_time_recovery_enabled = var.point_in_time_recovery
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = var.backup_retained_count
      }
    }

    maintenance_window {
      day  = var.maintenance_window_day
      hour = var.maintenance_window_hour
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }

    insights_config {
      query_insights_enabled  = true
      query_plans_per_minute  = 5
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    user_labels = var.labels
  }

  depends_on = [google_service_networking_connection.private]

  lifecycle {
    ignore_changes = [settings[0].disk_size]
  }
}

# ── DATABASES ────────────────────────────────────────

resource "google_sql_database" "this" {
  for_each = toset(var.databases)

  name     = each.value
  instance = google_sql_database_instance.this.name
  project  = var.project_id
}

# ── READ REPLICAS ────────────────────────────────────

resource "google_sql_database_instance" "replica" {
  count = var.read_replicas

  name                 = "${var.name}-replica-${count.index}-${random_id.suffix.hex}"
  project              = var.project_id
  region               = var.region
  database_version     = var.database_version
  master_instance_name = google_sql_database_instance.this.name
  deletion_protection  = var.deletion_protection

  replica_configuration {
    failover_target = false
  }

  settings {
    tier            = var.tier
    disk_autoresize = var.disk_autoresize

    ip_configuration {
      ipv4_enabled    = var.enable_public_ip
      private_network = var.network
    }

    user_labels = merge(var.labels, {
      role    = "replica"
      replica = tostring(count.index)
    })
  }

  depends_on = [google_sql_database_instance.this]
}
