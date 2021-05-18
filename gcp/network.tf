resource "google_compute_network" "exa" {
  count                   = var.network.new ? 1 : 0
  name                    = format("%s-%s", local.prefix, "network")
  mtu                     = var.network.mtu
  routing_mode            = var.network.routing
  auto_create_subnetworks = var.network.auto
}

resource "google_compute_subnetwork" "exa" {
  count                    = var.subnetwork.new ? 1 : 0
  name                     = format("%s-%s", local.prefix, "subnetwork")
  network                  = local.network.name
  region                   = local.region
  ip_cidr_range            = var.subnetwork.address
  private_ip_google_access = var.subnetwork.private
}

data "google_compute_subnetwork" "exa" {
  count  = var.subnetwork.new ? 0 : 1
  name   = var.subnetwork.name
  region = local.region
}

resource "google_compute_firewall" "exa_local" {
  name      = format("%s-%s", local.prefix, "allow-local")
  network   = local.network.name
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

resource "google_compute_firewall" "exa_lnet" {
  name      = format("%s-%s", local.prefix, "allow-lnet")
  network   = local.network.name
  direction = "INGRESS"
  target_tags = [
    local.prefix
  ]
  source_ranges = [
    local.subnetwork.address
  ]
  allow {
    protocol = "tcp"
    ports = [
      "988"
    ]
  }
}

resource "google_compute_firewall" "exa_repo" {
  name      = format("%s-%s", local.prefix, "allow-repo")
  network   = local.network.name
  direction = "INGRESS"
  target_tags = [
    local.http_tag
  ]
  source_ranges = [
    local.subnetwork.address
  ]
  allow {
    protocol = "tcp"
    ports = [
      "80"
    ]
  }
}

resource "google_compute_firewall" "exa_ssh" {
  count     = var.security.enable_ssh ? 1 : 0
  name      = format("%s-%s", local.prefix, "allow-ssh")
  network   = local.network.name
  direction = "INGRESS"
  target_tags = [
    local.prefix
  ]
  source_ranges = [
    var.security.ssh_source_range
  ]
  allow {
    protocol = "tcp"
    ports = [
      "22"
    ]
  }
}

resource "google_compute_firewall" "exa_http" {
  count     = var.security.enable_http ? 1 : 0
  name      = format("%s-%s", local.prefix, "allow-http")
  network   = local.network.name
  direction = "INGRESS"
  target_tags = [
    local.http_tag
  ]
  source_ranges = [
    var.security.http_source_range
  ]
  allow {
    protocol = "tcp"
    ports = [
      "80"
    ]
  }
}

resource "google_compute_router" "exa" {
  count   = var.network.nat ? 1 : 0
  name    = format("%s-%s", local.prefix, "router")
  region  = local.region
  network = local.network.name
}

resource "google_compute_router_nat" "exa" {
  count                              = var.network.nat ? 1 : 0
  name                               = format("%s-%s", local.prefix, "nat")
  router                             = google_compute_router.exa.0.name
  region                             = local.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name = local.subnetwork.name
    source_ip_ranges_to_nat = [
      "ALL_IP_RANGES"
    ]
  }
}
