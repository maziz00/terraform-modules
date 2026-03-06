output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.this.id
}

output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.this.name
}

output "network_self_link" {
  description = "The self-link of the VPC network"
  value       = google_compute_network.this.self_link
}

output "subnets" {
  description = "Map of subnet name to subnet details"
  value = {
    for k, v in google_compute_subnetwork.this : k => {
      id            = v.id
      self_link     = v.self_link
      ip_cidr_range = v.ip_cidr_range
      region        = v.region
    }
  }
}
