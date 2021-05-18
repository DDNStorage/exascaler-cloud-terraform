terraform {
  required_version = ">= 0.12"
}

provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = local.region
  zone        = var.zone
}

provider "google-beta" {
  credentials = file(var.credentials)
  project     = var.project
  region      = local.region
  zone        = var.zone
}

resource "random_id" "exa" {
  byte_length = 2
}

resource "google_runtimeconfig_config" "fs_config" {
  name = format("%s-%s", local.prefix, "fs-config")
}

resource "google_runtimeconfig_config" "role_config" {
  name = format("%s-%s", local.prefix, "role-config")
}

resource "google_runtimeconfig_config" "startup_config" {
  name = format("%s-%s", local.prefix, "startup-config")
}

resource "google_deployment_manager_deployment" "exa" {
  name = format("%s-%s", local.prefix, "deployment")
  target {
    config {
      content = data.template_file.startup_waiter.rendered
    }
  }
}

data "google_compute_image" "exa" {
  name    = var.image.name
  project = var.image.project
}

data "google_service_account" "service_account" {
  account_id = var.service_account
}

data "template_file" "startup_waiter" {
  template = file(format("%s/%s/%s", path.module, local.templates, "startup-waiter.yaml"))
  vars = {
    deployment = local.prefix
    number     = local.node_count
    timeout    = format("%ss", local.node_count * local.timeout)
    waiter     = format("%s-%s", local.prefix, "startup-waiter")
    parent     = google_runtimeconfig_config.startup_config.id
  }
}

data "template_file" "startup_script" {
  template = file(format("%s/%s/%s", path.module, local.templates, "startup-script.sh"))
  vars = {
    deployment     = local.prefix
    capacity       = local.capacity
    profile        = local.profile
    zone           = var.zone
    fsname         = var.fsname
    mgt_disk_type  = var.mgt.disk_type
    mgt_disk_size  = var.mgt.disk_size
    mnt_disk_type  = var.mnt.disk_type
    mnt_disk_size  = var.mnt.disk_size
    mds_node_count = var.mds.node_count
    mdt_disk_count = var.mdt.disk_count
    mdt_disk_type  = var.mdt.disk_type
    mdt_disk_size  = var.mdt.disk_size
    oss_node_count = var.oss.node_count
    ost_disk_count = var.ost.disk_count
    ost_disk_type  = var.ost.disk_type
    ost_disk_size  = var.ost.disk_size
  }
}

locals {
  product    = "exascaler-cloud"
  profile    = "Custom configuration profile"
  templates  = "templates"
  timeout    = 300
  region     = join("-", slice(split("-", var.zone), 0, 2))
  prefix     = format("%s-%s", local.product, random_id.exa.hex)
  ssh_key    = format("%s:%s", var.admin.username, file(var.admin.ssh_public_key))
  http_tag   = format("%s-%s", local.prefix, "http-server")
  node_count = var.mgs.node_count + var.mds.node_count + var.oss.node_count + var.cls.node_count
  capacity   = var.oss.node_count * var.ost.disk_count * var.ost.disk_size

  network = var.network.new ? {
    name = google_compute_network.exa.0.name
    } : {
    name = var.network.name
  }

  subnetwork = var.subnetwork.new ? {
    name    = google_compute_subnetwork.exa.0.name
    address = var.subnetwork.address
    } : {
    name    = var.subnetwork.name
    address = data.google_compute_subnetwork.exa.0.ip_cidr_range
  }

  labels = merge(
    data.google_compute_image.exa.labels,
    {
      deployment = local.prefix
    }
  )

  roles = {
    mgt = {
      kind  = "mgs",
      nodes = var.mgs.node_count,
      disks = var.mgt.disk_count,
      type  = var.mgt.disk_type,
      size  = var.mgt.disk_size,
      bus   = var.mgt.disk_bus
    },
    mnt = {
      kind  = "mgs",
      nodes = var.mgs.node_count,
      disks = var.mnt.disk_count,
      type  = var.mnt.disk_type,
      size  = var.mnt.disk_size,
      bus   = var.mnt.disk_bus
    },
    mdt = {
      kind  = "mds",
      nodes = var.mds.node_count,
      disks = var.mdt.disk_count,
      type  = var.mdt.disk_type,
      size  = var.mdt.disk_size,
      bus   = var.mdt.disk_bus
    },
    ost = {
      kind  = "oss",
      nodes = var.oss.node_count,
      disks = var.ost.disk_count,
      type  = var.ost.disk_type,
      size  = var.ost.disk_size,
      bus   = var.ost.disk_bus
    },
    clt = {
      kind  = "cls",
      nodes = var.cls.node_count,
      disks = var.clt.disk_count,
      type  = var.clt.disk_type,
      size  = var.clt.disk_size,
      bus   = var.clt.disk_bus
    }
  }

  disks = {
    for role, data in local.roles :
    role => {
      for pair in setproduct(range(data.nodes), range(data.disks)) :
      format("%s%s-%s%s", data.kind, pair[0], role, pair[1]) => {
        name  = format("%s-%s%s-%s%s", local.prefix, data.kind, pair[0], role, pair[1])
        host  = format("%s-%s%s", local.prefix, data.kind, pair[0])
        node  = pair[0]
        disk  = pair[1]
        role  = role
        type  = data.type
        size  = data.size
        index = data.disks * pair[0] + pair[1]
      }
    }
  }

  compute_disk = {
    for role, data in local.disks :
    role => {
      for key, value in data :
      key => value
      if value.type != "scratch"
    }
  }

  attached_disk = {
    for role, data in local.roles :
    role => {
      for node in range(data.nodes) :
      node => {
        for disk in range(data.disks) :
        format("%s%s-%s%s", data.kind, node, role, disk) =>
        format("%s-%s%s-%s%s", local.prefix, data.kind, node, role, disk)
        if data.type != "scratch"
      }
    }
  }

  scratch_disk = {
    for role, data in local.roles :
    role => {
      for node in range(data.nodes) :
      node => [
        for disk in range(data.disks) :
        data.bus
        if data.type == "scratch"
      ]
    }
  }
}
