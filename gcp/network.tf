# Copyright (c) 2024 DataDirect Networks, Inc.
# All Rights Reserved.

resource "google_compute_network" "exa" {
  provider                = google-beta
  count                   = var.network.new ? 1 : 0
  name                    = format("%s-%s", local.prefix, "network")
  mtu                     = var.network.mtu
  routing_mode            = var.network.routing
  auto_create_subnetworks = var.network.auto
}

resource "google_compute_subnetwork" "exa" {
  provider                 = google-beta
  count                    = var.subnetwork.new ? 1 : 0
  name                     = format("%s-%s", local.prefix, "subnetwork")
  network                  = local.network.id
  region                   = local.region
  ip_cidr_range            = var.subnetwork.address
  private_ip_google_access = var.subnetwork.private
}

resource "google_compute_firewall" "local" {
  provider  = google-beta
  count     = var.security.enable_local ? 1 : 0
  name      = format("%s-%s", local.prefix, "allow-local")
  network   = local.network.id
  direction = "INGRESS"
  source_tags = [
    local.prefix
  ]
  target_tags = [
    local.prefix
  ]
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "lnet" {
  provider  = google-beta
  count     = var.security.enable_local ? 1 : 0
  name      = format("%s-%s", local.prefix, "allow-lnet")
  network   = local.network.id
  direction = "INGRESS"
  target_tags = [
    local.prefix
  ]
  source_ranges = [
    var.subnetwork.address
  ]
  allow {
    protocol = "tcp"
    ports = [
      "988"
    ]
  }
}

resource "google_compute_firewall" "repo" {
  provider  = google-beta
  count     = var.security.enable_local ? 1 : 0
  name      = format("%s-%s", local.prefix, "allow-repo")
  network   = local.network.id
  direction = "INGRESS"
  target_tags = [
    local.http_tag
  ]
  source_ranges = [
    var.subnetwork.address
  ]
  allow {
    protocol = "tcp"
    ports = [
      "80"
    ]
  }
}

resource "google_compute_firewall" "ssh" {
  provider      = google-beta
  count         = var.security.enable_ssh ? 1 : 0
  name          = format("%s-%s", local.prefix, "allow-ssh")
  network       = local.network.id
  source_ranges = var.security.ssh_source_ranges
  direction     = "INGRESS"
  target_tags = [
    local.prefix
  ]
  allow {
    protocol = "tcp"
    ports = [
      "22"
    ]
  }
}

resource "google_compute_firewall" "http" {
  provider      = google-beta
  count         = var.security.enable_http ? 1 : 0
  name          = format("%s-%s", local.prefix, "allow-http")
  network       = local.network.id
  source_ranges = var.security.http_source_ranges
  direction     = "INGRESS"
  target_tags = [
    local.http_tag
  ]
  allow {
    protocol = "tcp"
    ports = [
      "80"
    ]
  }
}

resource "google_compute_router" "exa" {
  provider = google-beta
  count    = var.network.nat ? 1 : 0
  name     = format("%s-%s", local.prefix, "router")
  region   = local.region
  network  = local.network.id
}

resource "google_compute_address" "nat" {
  provider     = google-beta
  count        = var.network.nat ? 1 : 0
  name         = format("%s-%s", local.prefix, "nat-external-address")
  region       = local.region
  network_tier = "PREMIUM"
  address_type = "EXTERNAL"
}

resource "google_compute_router_nat" "exa" {
  provider                           = google-beta
  count                              = var.network.nat ? 1 : 0
  name                               = format("%s-%s", local.prefix, "nat")
  router                             = google_compute_router.exa.0.name
  region                             = local.region
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat.*.self_link
  subnetwork {
    name = local.subnetwork.id
    source_ip_ranges_to_nat = [
      "ALL_IP_RANGES"
    ]
  }
}
