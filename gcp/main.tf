# Copyright (c) 2024 DataDirect Networks, Inc.
# All Rights Reserved.

terraform {
  required_version = ">= 1.0.0"
}

provider "google-beta" {
  project = var.project
  region  = local.region
  zone    = var.zone
}

resource "random_id" "exa" {
  byte_length = 2
}

resource "google_runtimeconfig_config" "fs_config" {
  provider = google-beta
  name     = format("%s-%s", local.prefix, "fs-config")
}

resource "google_runtimeconfig_config" "startup_config" {
  provider = google-beta
  name     = format("%s-%s", local.prefix, "startup-config")
}

resource "google_deployment_manager_deployment" "exa" {
  provider = google-beta
  count    = var.waiter == "deploymentmanager" ? 1 : 0
  name     = format("%s-%d-%s-%s", local.prefix, local.node_count, "nodes", "deployment")
  target {
    config {
      content = local.waiter
    }
  }
  depends_on = [
    google_runtimeconfig_config.startup_config,
    google_compute_instance.mgs,
    google_compute_instance.mds,
    google_compute_instance.oss,
    google_compute_instance.cls
  ]
}

resource "null_resource" "waiter" {
  count = var.waiter == "sdk" ? 1 : 0
  triggers = {
    deployment = local.prefix
    count      = local.node_count
    timeout    = local.timeout
    project    = var.project
    zone       = var.zone
  }
  provisioner "local-exec" {
    when    = create
    command = format("%s/%s/%s", path.module, local.scripts, "startup-waiter.sh")
    environment = {
      config     = google_runtimeconfig_config.startup_config.name
      waiter     = format("%s-%s", local.prefix, "startup-waiter")
      count      = local.node_count
      deployment = local.prefix
      project    = var.project
      timeout    = format("%sS", local.node_count * local.timeout)
      zone       = var.zone
    }
  }
  depends_on = [
    google_runtimeconfig_config.startup_config,
    google_compute_instance.mgs,
    google_compute_instance.mds,
    google_compute_instance.oss,
    google_compute_instance.cls
  ]
}

resource "google_service_account" "exa" {
  provider     = google-beta
  count        = var.service_account.new ? 1 : 0
  account_id   = local.prefix
  display_name = local.prefix
  description  = format("%s %s", local.product, "Compute Service Account")
}

resource "google_project_iam_custom_role" "exa" {
  provider    = google-beta
  count       = var.service_account.new ? 1 : 0
  role_id     = replace(local.prefix, "-", ".")
  title       = format("%s %s %s", local.product, random_id.exa.hex, "Custom Role")
  description = format("%s %s", local.prefix, "custom role")
  permissions = [
    "compute.disks.get",
    "compute.disks.list",
    "compute.instances.get",
    "compute.instances.list",
    "runtimeconfig.configs.get",
    "runtimeconfig.configs.list",
    "runtimeconfig.variables.get",
    "runtimeconfig.variables.list",
    "runtimeconfig.variables.create",
    "runtimeconfig.variables.delete",
    "runtimeconfig.variables.update"
  ]
}

resource "google_project_iam_binding" "exa" {
  provider = google-beta
  count    = var.service_account.new ? 1 : 0
  role     = format("%s/%s/%s/%s", "projects", var.project, "roles", google_project_iam_custom_role.exa.0.role_id)
  project  = var.project
  members = [
    format("%s:%s", "serviceAccount", google_service_account.exa.0.email)
  ]
}

data "google_compute_image" "exa" {
  provider = google-beta
  project  = var.image.project
  family   = var.image.family
}

locals {
  loci       = "2.2.1"
  product    = "EXAScaler Cloud"
  profile    = "custom"
  scripts    = "scripts"
  templates  = "templates"
  timeout    = 300
  label      = lower(replace(local.product, " ", "-"))
  region     = join("-", slice(split("-", var.zone), 0, 2))
  prefix     = coalesce(var.prefix, format("%s-%s", local.label, random_id.exa.hex))
  ssh_key    = var.security.admin != null && var.security.public_key != null ? format("%s:%s", var.security.admin, file(var.security.public_key)) : null
  http_tag   = format("%s-%s", local.prefix, "http-server")
  node_count = var.mgs.node_count + var.mds.node_count + var.oss.node_count + var.cls.node_count

  service_account = var.service_account.new ? {
    email = google_service_account.exa.0.email
    } : {
    email = var.service_account.email
  }

  network = var.network.new ? {
    id = google_compute_network.exa.0.id
    } : {
    id = var.network.id
  }

  subnetwork = var.subnetwork.new ? {
    id = google_compute_subnetwork.exa.0.id
    } : {
    id = var.subnetwork.id
  }

  script = templatefile(
    format("%s/%s/%s", path.module, local.templates, "startup-script.tftpl"),
    {
      loci       = local.loci
      deployment = local.prefix
      profile    = local.profile
      fsname     = var.fsname
      mgs_type   = var.mgs.node_type
      mgs_count  = var.mgs.node_count
      mgt_type   = var.mgt.disk_type
      mgt_size   = var.mgt.disk_size
      mgt_count  = var.mgt.disk_count
      mgt_raid   = var.mgt.disk_raid
      mnt_type   = var.mnt.disk_type
      mnt_size   = var.mnt.disk_size
      mnt_count  = var.mnt.disk_count
      mnt_raid   = var.mnt.disk_raid
      mds_type   = var.mds.node_type
      mds_count  = var.mds.node_count
      mdt_type   = var.mdt.disk_type
      mdt_size   = var.mdt.disk_size
      mdt_count  = var.mdt.disk_count
      mdt_raid   = var.mdt.disk_raid
      oss_type   = var.oss.node_type
      oss_count  = var.oss.node_count
      ost_type   = var.ost.disk_type
      ost_size   = var.ost.disk_size
      ost_count  = var.ost.disk_count
      ost_raid   = var.ost.disk_raid
    }
  )

  waiter = templatefile(
    format("%s/%s/%s", path.module, local.templates, "startup-waiter.tftpl"),
    {
      deployment = local.prefix
      number     = local.node_count
      timeout    = format("%ss", local.node_count * local.timeout)
      waiter     = format("%s-%s", local.prefix, "startup-waiter")
      parent     = google_runtimeconfig_config.startup_config.id
    }
  )

  client = templatefile(
    format("%s/%s/%s", path.module, local.templates, "client-script.tftpl"),
    {
      mgs        = google_compute_address.mgs_int.0.address
      zone       = var.zone
      loci       = local.loci
      fsname     = var.fsname
      network    = local.network.id
      subnetwork = local.subnetwork.id
      deployment = local.prefix
    }
  )

  labels = merge(
    var.labels,
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
      iops  = var.mgt.disk_iops,
      mbps  = var.mgt.disk_mbps,
      size  = var.mgt.disk_size,
      bus   = var.mgt.disk_bus
    },
    mnt = {
      kind  = "mgs",
      nodes = var.mgs.node_count,
      disks = var.mnt.disk_count,
      type  = var.mnt.disk_type,
      iops  = var.mnt.disk_iops,
      mbps  = var.mnt.disk_mbps,
      size  = var.mnt.disk_size,
      bus   = var.mnt.disk_bus
    },
    mdt = {
      kind  = "mds",
      nodes = var.mds.node_count,
      disks = var.mdt.disk_count,
      type  = var.mdt.disk_type,
      iops  = var.mdt.disk_iops,
      mbps  = var.mdt.disk_mbps,
      size  = var.mdt.disk_size,
      bus   = var.mdt.disk_bus
    },
    ost = {
      kind  = "oss",
      nodes = var.oss.node_count,
      disks = var.ost.disk_count,
      type  = var.ost.disk_type,
      iops  = var.ost.disk_iops,
      mbps  = var.ost.disk_mbps,
      size  = var.ost.disk_size,
      bus   = var.ost.disk_bus
    },
    clt = {
      kind  = "cls",
      nodes = var.cls.node_count,
      disks = var.clt.disk_count,
      type  = var.clt.disk_type,
      iops  = var.clt.disk_iops,
      mbps  = var.clt.disk_mbps,
      size  = var.clt.disk_size,
      bus   = var.clt.disk_bus
    }
  }

  disks = {
    for role, data in local.roles :
    role => {
      for pair in setproduct(range(data.nodes), range(data.disks)) :
      format("%s%s-%s%s", data.kind, pair[0], role, pair[1]) => {
        name  = format("%s-%s%s-%s%s-%s", local.prefix, data.kind, pair[0], role, pair[1], "disk")
        host  = format("%s-%s%s", local.prefix, data.kind, pair[0])
        node  = pair[0]
        disk  = pair[1]
        role  = role
        type  = data.type
        iops  = data.iops
        mbps  = data.mbps
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
      node => [
        for disk in range(data.disks) :
        format("%s%s-%s%s", data.kind, node, role, disk)
        if data.type != "scratch"
      ]
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
