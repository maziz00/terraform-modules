output "cluster_id" {
  description = "The unique identifier of the GKE cluster"
  value       = google_container_cluster.this.id
}

output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.this.name
}

output "cluster_endpoint" {
  description = "The IP address of the GKE master"
  value       = google_container_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded public certificate of the cluster CA"
  value       = google_container_cluster.this.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "The location (region) of the cluster"
  value       = google_container_cluster.this.location
}

output "workload_identity_pool" {
  description = "Workload Identity pool for IRSA-equivalent on GCP"
  value       = var.enable_workload_identity ? "${var.project_id}.svc.id.goog" : null
}
