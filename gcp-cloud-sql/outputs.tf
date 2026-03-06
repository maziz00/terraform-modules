output "instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = google_sql_database_instance.this.name
}

output "instance_connection_name" {
  description = "The connection name for Cloud SQL Proxy"
  value       = google_sql_database_instance.this.connection_name
}

output "private_ip_address" {
  description = "The private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.this.private_ip_address
}

output "public_ip_address" {
  description = "The public IP address of the Cloud SQL instance (if enabled)"
  value       = var.enable_public_ip ? google_sql_database_instance.this.public_ip_address : null
}

output "replica_connection_names" {
  description = "Connection names for read replicas"
  value       = google_sql_database_instance.replica[*].connection_name
}

output "replica_private_ips" {
  description = "Private IP addresses of read replicas"
  value       = google_sql_database_instance.replica[*].private_ip_address
}
