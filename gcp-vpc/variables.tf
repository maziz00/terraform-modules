variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    region        = string
    ip_cidr_range = string
    secondary_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
}

variable "enable_cloud_nat" {
  description = "Create Cloud NAT for outbound internet access from private instances"
  type        = bool
  default     = true
}

variable "cloud_nat_regions" {
  description = "Regions to create Cloud NAT routers (defaults to all subnet regions)"
  type        = list(string)
  default     = []
}

variable "firewall_rules" {
  description = "Map of custom firewall rules"
  type = map(object({
    direction     = string
    priority      = optional(number, 1000)
    ranges        = list(string)
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    target_tags = optional(list(string))
    source_tags = optional(list(string))
  }))
  default = {}
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs on all subnets"
  type        = bool
  default     = true
}
