variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for the GKE cluster"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "network" {
  description = "VPC network name or self-link"
  type        = string
}

variable "subnetwork" {
  description = "VPC subnetwork name or self-link"
  type        = string
}

variable "pods_range_name" {
  description = "Name of the secondary IP range for pods"
  type        = string
}

variable "services_range_name" {
  description = "Name of the secondary IP range for services"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the GKE master nodes (must be /28)"
  type        = string
  default     = "172.16.0.0/28"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster (e.g., 1.29)"
  type        = string
  default     = "1.29"
}

variable "enable_private_nodes" {
  description = "Nodes only have internal IP addresses"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "The master's internal IP is used as the cluster endpoint"
  type        = bool
  default     = false
}

variable "master_authorized_networks" {
  description = "List of CIDR blocks authorized to access the master endpoint"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "node_pools" {
  description = "Map of node pool configurations"
  type = map(object({
    machine_type   = string
    min_count      = number
    max_count      = number
    initial_count  = optional(number, 1)
    disk_size_gb   = optional(number, 100)
    disk_type      = optional(string, "pd-standard")
    preemptible    = optional(bool, false)
    spot           = optional(bool, false)
    labels         = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
  default = {}
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity for pod-level GCP IAM"
  type        = bool
  default     = true
}

variable "enable_binary_authorization" {
  description = "Enable Binary Authorization for container image verification"
  type        = bool
  default     = false
}

variable "enable_shielded_nodes" {
  description = "Enable Shielded GKE Nodes (Secure Boot + vTPM)"
  type        = bool
  default     = true
}

variable "release_channel" {
  description = "Release channel for GKE version management (RAPID, REGULAR, STABLE)"
  type        = string
  default     = "REGULAR"
}

variable "labels" {
  description = "Labels to apply to the cluster"
  type        = map(string)
  default     = {}
}
