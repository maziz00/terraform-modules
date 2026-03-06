# ─────────────────────────────────────────────────────
# GCP VPC Module
# VPC, subnets, Cloud NAT, firewall rules, flow logs
# ─────────────────────────────────────────────────────

resource "google_compute_network" "this" {
  name                    = var.name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

# ── SUBNETS ──────────────────────────────────────────

resource "google_compute_subnetwork" "this" {
  for_each = var.subnets

  name          = each.key
  project       = var.project_id
  region        = each.value.region
  network       = google_compute_network.this.id
  ip_cidr_range = each.value.ip_cidr_range

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }

  private_ip_google_access = true
}

# ── CLOUD NAT ────────────────────────────────────────

locals {
  nat_regions = length(var.cloud_nat_regions) > 0 ? var.cloud_nat_regions : distinct([for s in var.subnets : s.region])
}

resource "google_compute_router" "this" {
  for_each = var.enable_cloud_nat ? toset(local.nat_regions) : toset([])

  name    = "${var.name}-router-${each.key}"
  project = var.project_id
  region  = each.key
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "this" {
  for_each = var.enable_cloud_nat ? toset(local.nat_regions) : toset([])

  name    = "${var.name}-nat-${each.key}"
  project = var.project_id
  region  = each.key
  router  = google_compute_router.this[each.key].name

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# ── FIREWALL RULES ───────────────────────────────────

resource "google_compute_firewall" "this" {
  for_each = var.firewall_rules

  name      = "${var.name}-${each.key}"
  project   = var.project_id
  network   = google_compute_network.this.id
  direction = each.value.direction
  priority  = each.value.priority

  source_ranges = each.value.direction == "INGRESS" ? each.value.ranges : null
  destination_ranges = each.value.direction == "EGRESS" ? each.value.ranges : null

  target_tags = each.value.target_tags
  source_tags = each.value.source_tags

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = each.value.deny
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }
}
