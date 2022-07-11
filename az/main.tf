terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.10.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription
  partner_id      = "e798abf8-8847-4da5-9f28-5cc3ebbfdfcf"
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

data "template_file" "script" {
  template = file(format("%s/%s/%s", path.module, local.templates, "startup-script.sh"))
  vars = {
    loci       = local.loci
    deployment = local.prefix
    profile    = local.profile
    fsname     = var.fsname
    mgstype    = var.mgs.node_type
    mgscount   = var.mgs.node_count
    mgttype    = var.mgt.disk_type
    mgtsize    = var.mgt.disk_size
    mgtcount   = var.mgt.disk_count
    mgtraid    = var.mgt.disk_raid
    mnttype    = var.mnt.disk_type
    mntsize    = var.mnt.disk_size
    mntcount   = var.mnt.disk_count
    mntraid    = var.mnt.disk_raid
    mdstype    = var.mds.node_type
    mdscount   = var.mds.node_count
    mdttype    = var.mdt.disk_type
    mdtsize    = var.mdt.disk_size
    mdtcount   = var.mdt.disk_count
    mdtraid    = var.mdt.disk_raid
    osstype    = var.oss.node_type
    osscount   = var.oss.node_count
    osttype    = var.ost.disk_type
    ostsize    = var.ost.disk_size
    ostcount   = var.ost.disk_count
    ostraid    = var.ost.disk_raid
  }
}

data "template_file" "dashboard" {
  template = file(format("%s/%s/%s", path.module, local.templates, "dashboard.json"))
  vars = {
    subscription_name = data.azurerm_subscription.exa.display_name
    subscription_id   = data.azurerm_subscription.exa.subscription_id
    location          = local.resource_group.location
    resourcegroup     = local.resource_group.name
    network           = local.network.name
    management        = azurerm_network_interface.mgs.0.private_ip_address
    http              = format("http://%s", local.http)
    ssh               = format("ssh -A %s@%s", var.security.user_name, local.ssh)
    deployment        = local.prefix
    capacity          = local.capacity
    profile           = local.profile
    fsname            = var.fsname
    piblic            = length(local.public) == 0 ? "disabled" : join(", ", local.public)
    remote            = length(local.remote) == 0 ? "disabled" : join(" and ", local.remote)
    image             = local.image
    loci              = local.loci
  }
}

data "template_file" "client_script" {
  template = file(format("%s/%s/%s", path.module, local.templates, "client-script.sh"))
  vars = {
    mgs        = azurerm_network_interface.mgs.0.private_ip_address
    loci       = local.loci
    fsname     = var.fsname
    location   = local.resource_group.location
    network    = local.network.name
    subnetwork = local.subnet.name
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

resource "azurerm_app_configuration" "fs_config" {
  name                = format("%s-%s", local.prefix, "fs-config")
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  sku                 = "standard"
  tags                = local.tags
}

resource "azurerm_user_assigned_identity" "exa" {
  name                = format("%s-%s", local.prefix, "user-assigned-identity")
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  tags                = local.tags
}

resource "azurerm_role_definition" "exa" {
  name        = format("%s-%s", local.prefix, "role-definition")
  description = "Custom role for EXAScaler Cloud management operations"
  scope       = local.resource_group.id
  permissions {
    actions = [
      "Microsoft.AppConfiguration/checkNameAvailability/read",
      "Microsoft.AppConfiguration/configurationStores/ListKeys/action",
      "Microsoft.AppConfiguration/configurationStores/ListKeyValue/action",
      "Microsoft.AppConfiguration/configurationStores/read",
      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Network/networkInterfaces/read",
      "Microsoft.Network/networkInterfaces/ipconfigurations/read",
      "Microsoft.Network/publicIPAddresses/read",
      "Microsoft.Resources/subscriptions/read",
      "Microsoft.Resources/subscriptions/resourcegroups/resources/read"
    ]
    data_actions = [
      "Microsoft.AppConfiguration/configurationStores/keyValues/read",
      "Microsoft.AppConfiguration/configurationStores/keyValues/write",
      "Microsoft.AppConfiguration/configurationStores/keyValues/delete"
    ]
  }
}

resource "azurerm_role_assignment" "exa" {
  scope              = local.resource_group.id
  principal_id       = azurerm_user_assigned_identity.exa.principal_id
  role_definition_id = azurerm_role_definition.exa.role_definition_resource_id
}

resource "azurerm_marketplace_agreement" "exa" {
  count     = var.image.accept ? 1 : 0
  publisher = var.image.publisher
  offer     = var.image.offer
  plan      = var.image.sku
}

resource "azurerm_portal_dashboard" "exa" {
  name                 = format("%s-%s", local.prefix, "dashboard")
  resource_group_name  = local.resource_group.name
  location             = local.resource_group.location
  dashboard_properties = data.template_file.dashboard.rendered
  tags = merge(
    local.tags,
    {
      hidden-title = format("%s %s", local.product, random_id.exa.hex)
    }
  )
  depends_on = [
    azurerm_virtual_machine_extension.cls
  ]
}

locals {
  loci      = "2.0.0"
  product   = "EXAScaler Cloud"
  version   = "6.1.0"
  profile   = "custom"
  templates = "templates"
  label     = lower(replace(local.product, " ", "-"))
  prefix    = coalesce(var.prefix, format("%s-%s", local.label, random_id.exa.hex))
  sshkey    = file(var.security.ssh_public_key)
  zone      = var.availability.type == "zone" ? var.availability.zone : null
  zones     = var.availability.type == "zone" ? [var.availability.zone] : null
  targets   = var.oss.node_count * var.ost.disk_count
  timeout   = format("%dm", 30 * local.targets)
  capacity  = local.targets * var.ost.disk_size
  settings  = jsonencode(local.script)
  image     = var.image.sku
  http      = var.mgs.public_ip && var.security.enable_http ? azurerm_public_ip.mgs.0.fqdn : azurerm_network_interface.mgs.0.private_ip_address
  ssh       = var.mgs.public_ip && var.security.enable_ssh ? azurerm_public_ip.mgs.0.ip_address : azurerm_network_interface.mgs.0.private_ip_address

  script = {
    script = base64gzip(data.template_file.script.rendered)
  }

  tags = merge(
    var.tags,
    {
      deployment = local.prefix
      product    = local.product
      version    = local.version
    }
  )

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

  nodes = {
    mgs = {
      public       = var.mgs.public_ip,
      description  = "management server",
      availability = var.availability == "set" && var.mgs.node_count > 1
    },
    mds = {
      public       = var.mds.public_ip,
      description  = "metadata server",
      availability = var.availability == "set" && var.mds.node_count > 1
    }
    oss = {
      public       = var.oss.public_ip,
      description  = "storage servers",
      availability = var.availability == "set" && var.oss.node_count > 1
    }
    cls = {
      public       = var.cls.public_ip,
      description  = "compute clients",
      availability = var.availability == "set" && var.cls.node_count > 1
    }
  }

  public = [
    for node, data in local.nodes :
    data.description if data.public
  ]

  protocols = {
    ssh = {
      enabled     = length(local.public) > 0 && var.security.enable_ssh
      description = "SSH"
    }
    http = {
      enabled     = var.mgs.public_ip && var.security.enable_http
      description = "HTTP"
    }
  }

  remote = [
    for protocol, data in local.protocols :
    data.description if data.enabled
  ]
}
