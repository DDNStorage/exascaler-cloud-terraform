resource "google_compute_disk" "mgs" {
  provider = google-beta
  count    = var.mgs.node_count
  image    = data.google_compute_image.exa.self_link
  name     = format("%s-%s%d-%s", local.prefix, "mgs", count.index, "boot-disk")
  type     = var.boot.disk_type
  zone     = var.zone
  labels   = local.labels
}

resource "google_compute_disk" "mgt" {
  provider = google-beta
  for_each = local.compute_disk.mgt
  type     = each.value.type
  size     = each.value.size
  name     = each.value.name
  zone     = var.zone
  labels = merge(
    local.labels,
    {
      name                = each.value.name,
      lustre_target_host  = each.value.host,
      lustre_target_role  = each.value.role,
      lustre_target_index = each.value.index
    }
  )
}

resource "google_compute_disk" "mnt" {
  provider = google-beta
  for_each = local.compute_disk.mnt
  type     = each.value.type
  size     = each.value.size
  name     = each.value.name
  zone     = var.zone
  labels = merge(
    local.labels,
    {
      name                = each.value.name,
      lustre_target_host  = each.value.host,
      lustre_target_role  = each.value.role,
      lustre_target_index = each.value.index
    }
  )
}

resource "google_compute_address" "mgs_int" {
  provider     = google-beta
  count        = var.mgs.node_count
  name         = format("%s-%s%d-%s", local.prefix, "mgs", count.index, "internal-address")
  description  = format("%s-%s%d", local.prefix, "mgs", count.index)
  subnetwork   = local.subnetwork.id
  address_type = "INTERNAL"
}

resource "google_compute_address" "mgs_ext" {
  provider     = google-beta
  count        = var.mgs.public_ip ? var.mgs.node_count : 0
  name         = format("%s-%s%d-%s", local.prefix, "mgs", count.index, "external-address")
  description  = format("%s-%s%d", local.prefix, "mgs", count.index)
  network_tier = var.network.tier
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "mgs" {
  provider                  = google-beta
  count                     = var.mgs.node_count
  name                      = format("%s-%s%d", local.prefix, "mgs", count.index)
  zone                      = var.zone
  machine_type              = var.mgs.node_type
  min_cpu_platform          = var.mgs.node_cpu
  allow_stopping_for_update = true

  metadata = {
    enable-oslogin         = var.security.enable_os_login
    block-project-ssh-keys = var.security.block_project_keys
    startup-script         = local.script
    ssh-keys               = local.ssh_key
  }

  scheduling {
    on_host_maintenance = "MIGRATE"
  }

  boot_disk {
    source      = google_compute_disk.mgs[count.index].self_link
    device_name = google_compute_disk.mgs[count.index].name
  }

  dynamic "attached_disk" {
    for_each = local.attached_disk.mgt[count.index]
    content {
      source      = google_compute_disk.mgt[attached_disk.value].self_link
      device_name = google_compute_disk.mgt[attached_disk.value].name
    }
  }

  dynamic "attached_disk" {
    for_each = local.attached_disk.mnt[count.index]
    content {
      source      = google_compute_disk.mnt[attached_disk.value].self_link
      device_name = google_compute_disk.mnt[attached_disk.value].name
    }
  }

  dynamic "scratch_disk" {
    for_each = local.scratch_disk.mgt[count.index]
    content {
      interface = scratch_disk.value
    }
  }

  dynamic "scratch_disk" {
    for_each = local.scratch_disk.mnt[count.index]
    content {
      interface = scratch_disk.value
    }
  }

  service_account {
    email = local.service_account.email
    scopes = [
      "cloud-platform"
    ]
  }

  network_interface {
    subnetwork = local.subnetwork.id
    nic_type   = var.mgs.nic_type
    network_ip = google_compute_address.mgs_int[count.index].address
    dynamic "access_config" {
      for_each = var.mgs.public_ip ? [{}] : []
      content {
        network_tier = var.network.tier
        nat_ip       = google_compute_address.mgs_ext[count.index].address
      }
    }
  }

  tags = [
    local.prefix,
    local.http_tag
  ]

  labels = merge(
    local.labels,
    {
      lustre_type  = "mgt"
      lustre_index = count.index
    }
  )

  depends_on = [
    google_runtimeconfig_config.fs_config,
    google_runtimeconfig_config.startup_config
  ]
}
