resource "google_compute_disk" "cls" {
  provider = google-beta
  count    = var.cls.node_count
  image    = data.google_compute_image.exa.self_link
  name     = format("%s-%s%d-%s", local.prefix, "cls", count.index, "boot-disk")
  type     = var.boot.disk_type
  zone     = var.zone
  labels   = local.labels
}

resource "google_compute_disk" "clt" {
  provider = google-beta
  for_each = local.compute_disk.clt
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

resource "google_compute_address" "cls_int" {
  provider     = google-beta
  count        = var.cls.node_count
  name         = format("%s-%s%d-%s", local.prefix, "cls", count.index, "internal-address")
  description  = format("%s-%s%d", local.prefix, "cls", count.index)
  subnetwork   = local.subnetwork.id
  address_type = "INTERNAL"
}

resource "google_compute_address" "cls_ext" {
  provider     = google-beta
  count        = var.cls.public_ip ? var.cls.node_count : 0
  name         = format("%s-%s%d-%s", local.prefix, "cls", count.index, "external-address")
  description  = format("%s-%s%d", local.prefix, "cls", count.index)
  network_tier = var.network.tier
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "cls" {
  provider                  = google-beta
  count                     = var.cls.node_count
  name                      = format("%s-%s%d", local.prefix, "cls", count.index)
  zone                      = var.zone
  machine_type              = var.cls.node_type
  min_cpu_platform          = var.cls.node_cpu
  allow_stopping_for_update = true

  metadata = {
    block-project-ssh-keys = var.security.block_project_keys
    startup-script         = data.template_file.startup_script.rendered
    ssh-keys               = local.ssh_key
  }

  scheduling {
    on_host_maintenance = "MIGRATE"
  }

  boot_disk {
    source      = google_compute_disk.cls[count.index].self_link
    device_name = google_compute_disk.cls[count.index].name
  }

  dynamic "attached_disk" {
    for_each = local.attached_disk.clt[count.index]
    content {
      source      = google_compute_disk.clt[attached_disk.value].self_link
      device_name = google_compute_disk.clt[attached_disk.value].name
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
    subnetwork = local.subnetwork.id
    nic_type   = var.cls.nic_type
    network_ip = google_compute_address.cls_int[count.index].address
    dynamic "access_config" {
      for_each = var.cls.public_ip ? [{}] : []
      content {
        network_tier = var.network.tier
        nat_ip       = google_compute_address.cls_ext[count.index].address
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
