resource "google_compute_disk" "ost" {
  for_each = local.compute_disk.ost
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

resource "google_compute_instance" "oss" {
  count            = var.oss.node_count
  name             = format("%s-%s%d", local.prefix, "oss", count.index)
  zone             = var.zone
  machine_type     = var.oss.node_type
  min_cpu_platform = var.oss.node_cpu

  metadata = {
    startup-script = data.template_file.startup_script.rendered
    ssh-keys       = local.ssh_key
  }

  boot_disk {
    auto_delete = var.boot.auto_delete
    initialize_params {
      image = data.google_compute_image.exa.self_link
      type  = var.boot.disk_type
    }
  }

  dynamic "attached_disk" {
    for_each = local.attached_disk.ost[count.index]
    content {
      source      = google_compute_disk.ost[attached_disk.key].id
      device_name = attached_disk.value
    }
  }

  dynamic "scratch_disk" {
    for_each = local.scratch_disk.ost[count.index]
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
    subnetwork = local.subnetwork.name
    nic_type   = var.oss.nic_type
    dynamic "access_config" {
      for_each = var.oss.public_ip ? [{}] : []
      content {
        network_tier = var.network.tier
      }
    }
  }

  tags = [
    local.prefix
  ]

  labels = merge(
    local.labels,
    {
      lustre_type  = "ost",
      lustre_index = count.index
    }
  )

  depends_on = [
    google_runtimeconfig_config.fs_config,
    google_runtimeconfig_config.role_config,
    google_runtimeconfig_config.startup_config
  ]
}
