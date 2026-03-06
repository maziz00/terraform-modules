variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for the Cloud SQL instance"
  type        = string
}

variable "name" {
  description = "Name of the Cloud SQL instance"
  type        = string
}

variable "database_version" {
  description = "Database engine version (e.g., POSTGRES_15, MYSQL_8_0)"
  type        = string
  default     = "POSTGRES_15"
}

variable "tier" {
  description = "Machine tier for the instance (e.g., db-custom-2-8192)"
  type        = string
  default     = "db-custom-2-8192"
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 50
}

variable "disk_autoresize" {
  description = "Enable automatic disk size increase"
  type        = bool
  default     = true
}

variable "disk_autoresize_limit" {
  description = "Maximum disk size in GB for autoresize (0 = unlimited)"
  type        = number
  default     = 500
}

variable "network" {
  description = "VPC network self-link for private IP"
  type        = string
}

variable "enable_public_ip" {
  description = "Assign a public IP to the instance (not recommended for production)"
  type        = bool
  default     = false
}

variable "authorized_networks" {
  description = "List of authorized networks for public IP access"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "availability_type" {
  description = "Availability type: REGIONAL for HA, ZONAL for single zone"
  type        = string
  default     = "REGIONAL"
}

variable "backup_enabled" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "backup_start_time" {
  description = "Start time for the daily backup window (HH:MM format, UTC)"
  type        = string
  default     = "02:00"
}

variable "backup_retained_count" {
  description = "Number of automated backups to retain"
  type        = number
  default     = 14
}

variable "point_in_time_recovery" {
  description = "Enable point-in-time recovery (binary logging for MySQL, WAL for PostgreSQL)"
  type        = bool
  default     = true
}

variable "maintenance_window_day" {
  description = "Day of week for maintenance window (1=Mon, 7=Sun)"
  type        = number
  default     = 7
}

variable "maintenance_window_hour" {
  description = "Hour of day for maintenance window (0-23, UTC)"
  type        = number
  default     = 3
}

variable "deletion_protection" {
  description = "Prevent accidental deletion of the instance"
  type        = bool
  default     = true
}

variable "database_flags" {
  description = "Map of database flags to set"
  type        = map(string)
  default     = {}
}

variable "databases" {
  description = "List of databases to create"
  type        = list(string)
  default     = []
}

variable "read_replicas" {
  description = "Number of read replicas to create"
  type        = number
  default     = 0
}

variable "labels" {
  description = "Labels to apply to the instance"
  type        = map(string)
  default     = {}
}
