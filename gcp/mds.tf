resource "google_compute_disk" "mdt" {
  for_each = local.compute_disk.mdt
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

resource "google_compute_instance" "mds" {
  provider         = google-beta
  count            = var.mds.node_count
  name             = format("%s-%s%d", local.prefix, "mds", count.index)
  zone             = var.zone
  machine_type     = var.mds.node_type
  min_cpu_platform = var.mds.node_cpu

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
    for_each = local.attached_disk.mdt[count.index]
    content {
      source      = google_compute_disk.mdt[attached_disk.key].id
      device_name = attached_disk.value
    }
  }

  dynamic "scratch_disk" {
    for_each = local.scratch_disk.mdt[count.index]
    content {
      interface = scratch_disk.value
    }
  }

  service_account {
    email = data.google_service_account.service_account.email
    scopes = [
      "cloud-platform"
    ]
  }

  network_interface {
    subnetwork = local.subnetwork.name
    nic_type   = var.mds.nic_type
    dynamic "access_config" {
      for_each = var.mds.public_ip ? [{}] : []
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
      lustre_type  = "mdt"
      lustre_index = count.index
    }
  )

  depends_on = [
    google_runtimeconfig_config.fs_config,
    google_runtimeconfig_config.role_config,
    google_runtimeconfig_config.startup_config
  ]
}
