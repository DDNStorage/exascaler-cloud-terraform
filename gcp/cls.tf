resource "google_compute_disk" "clt" {
  for_each = local.compute_disk.clt
  type     = each.value.type
  size     = each.value.size
  name     = each.value.name
  zone     = var.zone
}

resource "google_compute_instance" "cls" {
  count            = var.cls.node_count
  name             = format("%s-%s%d", local.prefix, "cls", count.index)
  zone             = var.zone
  machine_type     = var.cls.node_type
  min_cpu_platform = var.cls.node_cpu

  metadata = {
    startup-script = data.template_file.startup_script.rendered
    ssh-keys       = local.ssh_key
  }

  scheduling {
    on_host_maintenance = "TERMINATE"
  }

  boot_disk {
    auto_delete = var.boot.auto_delete
    initialize_params {
      image = data.google_compute_image.exa.self_link
      type  = var.boot.disk_type
    }
  }

  dynamic "attached_disk" {
    for_each = local.attached_disk.clt[count.index]
    content {
      source      = google_compute_disk.clt[attached_disk.key].id
      device_name = attached_disk.value
    }
  }

  dynamic "scratch_disk" {
    for_each = local.scratch_disk.clt[count.index]
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
    nic_type   = var.cls.nic_type
    dynamic "access_config" {
      for_each = var.cls.public_ip ? [{}] : []
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
      lustre_type  = "clt"
      lustre_index = count.index
    }
  )

  depends_on = [
    google_runtimeconfig_config.fs_config,
    google_runtimeconfig_config.role_config,
    google_runtimeconfig_config.startup_config
  ]
}
