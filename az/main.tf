terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion = var.boot.auto_delete
    }
  }
}

data "azurerm_subscription" "exa" {
  subscription_id = var.subscription
}

data "azurerm_resource_group" "exa" {
  count = var.resource_group.new ? 0 : 1
  name  = var.resource_group.name
}

data "azurerm_proximity_placement_group" "exa" {
  count               = var.proximity_placement_group.new ? 0 : 1
  name                = var.proximity_placement_group.name
  resource_group_name = local.resource_group.name
}

data "template_file" "exa" {
  template = file(format("%s/%s/%s", path.module, local.templates, "startup-script.sh"))
  vars = {
    deployment     = local.prefix
    capacity       = local.capacity
    profile        = local.profile
    zone           = local.resource_group.location
    fsname         = var.fsname
    mnt_disk_type  = var.mnt.disk_type
    mnt_disk_size  = var.mnt.disk_size
    mgt_disk_type  = var.mgt.disk_type
    mgt_disk_size  = var.mgt.disk_size
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

resource "random_id" "exa" {
  byte_length = 2
}

resource "azurerm_resource_group" "exa" {
  count    = var.resource_group.new ? 1 : 0
  name     = format("%s-%s", local.prefix, "resource-group")
  location = var.location
  tags     = local.tags
}

resource "azurerm_proximity_placement_group" "exa" {
  count               = var.proximity_placement_group.new ? 1 : 0
  name                = format("%s-%s", local.prefix, "proximity-placement-group")
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  tags                = local.tags
}

resource "azurerm_storage_account" "exa" {
  name                     = replace(local.prefix, "-", "")
  location                 = local.resource_group.location
  resource_group_name      = local.resource_group.name
  account_tier             = var.storage_account.tier
  account_replication_type = var.storage_account.replication
  account_kind             = var.storage_account.kind
  tags                     = local.tags
}

resource "azurerm_app_configuration" "role_config" {
  name                = format("%s-%s", local.prefix, "role-config")
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  sku                 = "standard"
  tags                = local.tags
}

resource "azurerm_app_configuration" "fs_config" {
  name                = format("%s-%s", local.prefix, "fs-config")
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  sku                 = "standard"
  tags                = local.tags
}

locals {
  product   = "exascaler-cloud"
  profile   = "Custom configuration profile"
  templates = "templates"
  prefix    = format("%s-%s", local.product, random_id.exa.hex)
  sshkey    = file(var.admin.ssh_public_key)
  script    = base64encode(data.template_file.exa.rendered)
  zone      = var.zone == 0 ? null : var.zone
  zones     = var.zone == 0 ? null : [var.zone]
  capacity  = var.oss.node_count * var.ost.disk_count * var.ost.disk_size

  tags = {
    "product"    = "EXAScaler Cloud"
    "version"    = var.image.version
    "deployment" = local.prefix
  }

  resource_group = var.resource_group.new ? {
    id       = azurerm_resource_group.exa.0.id
    name     = azurerm_resource_group.exa.0.name
    location = azurerm_resource_group.exa.0.location
    } : {
    id       = data.azurerm_resource_group.exa.0.id
    name     = data.azurerm_resource_group.exa.0.name
    location = data.azurerm_resource_group.exa.0.location
  }

  proximity_placement_group = var.proximity_placement_group.new ? {
    id   = azurerm_proximity_placement_group.exa.0.id
    name = azurerm_proximity_placement_group.exa.0.name
    } : {
    id   = data.azurerm_proximity_placement_group.exa.0.id
    name = data.azurerm_proximity_placement_group.exa.0.name
  }

  network = var.network.new ? {
    id   = azurerm_virtual_network.exa.0.id
    name = azurerm_virtual_network.exa.0.name
    } : {
    id   = data.azurerm_virtual_network.exa.0.id
    name = data.azurerm_virtual_network.exa.0.name
  }

  subnet = var.subnet.new ? {
    id   = azurerm_subnet.exa.0.id
    name = azurerm_subnet.exa.0.name
    } : {
    id   = data.azurerm_subnet.exa.0.id
    name = data.azurerm_subnet.exa.0.name
  }

  roles = {
    mgt = {
      owner = "mgs",
      nodes = var.mgs.node_count,
      disks = var.mgt.disk_count,
      cache = var.mgt.disk_cache,
      type  = var.mgt.disk_type,
      size  = var.mgt.disk_size
    },
    mnt = {
      owner = "mgs",
      nodes = var.mgs.node_count,
      disks = var.mnt.disk_count,
      cache = var.mnt.disk_cache,
      type  = var.mnt.disk_type,
      size  = var.mnt.disk_size
    },
    mdt = {
      owner = "mds",
      nodes = var.mds.node_count,
      disks = var.mdt.disk_count,
      cache = var.mdt.disk_cache,
      type  = var.mdt.disk_type,
      size  = var.mdt.disk_size
    },
    ost = {
      owner = "oss",
      nodes = var.oss.node_count,
      disks = var.ost.disk_count,
      cache = var.ost.disk_cache,
      type  = var.ost.disk_type,
      size  = var.ost.disk_size
    },
    clt = {
      owner = "cls",
      nodes = var.cls.node_count,
      disks = var.clt.disk_count,
      cache = var.clt.disk_cache,
      type  = var.clt.disk_type,
      size  = var.clt.disk_size
    }
  }

  disks = {
    for role, data in local.roles :
    role => {
      for pair in setproduct(range(data.nodes), range(data.disks)) :
      format("%s%s-%s%s", data.owner, pair[0], role, pair[1]) => {
        name  = format("%s-%s%s-%s%s-%s", local.prefix, data.owner, pair[0], role, pair[1], "disk")
        host  = format("%s-%s%s", local.prefix, data.owner, pair[0])
        node  = pair[0]
        disk  = pair[1]
        role  = role
        type  = data.type
        size  = data.size
        cache = data.cache
        index = data.disks * pair[0] + pair[1]
      }
    }
  }
}
