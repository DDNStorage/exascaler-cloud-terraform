# Copyright (c) 2024 DataDirect Networks, Inc.
# All Rights Reserved.

resource "azurerm_public_ip" "cls" {
  count               = var.cls.public_ip ? var.cls.node_count : 0
  name                = format("%s-%s%d-%s", local.prefix, "cls", count.index, "public-ip")
  domain_name_label   = format("%s-%s%d", local.prefix, "cls", count.index)
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  zones               = local.zones
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = merge(
    local.tags,
    {
      lustre_type  = "clt",
      lustre_index = count.index
    }
  )
}

resource "azurerm_network_interface" "cls" {
  count                          = var.cls.node_count
  name                           = format("%s-%s%d-%s", local.prefix, "cls", count.index, "network-interface")
  location                       = local.resource_group.location
  resource_group_name            = local.resource_group.name
  accelerated_networking_enabled = var.cls.accelerated_network
  ip_configuration {
    name                          = format("%s-%s%d-%s", local.prefix, "cls", count.index, "private-ip")
    subnet_id                     = local.subnet.id
    public_ip_address_id          = var.cls.public_ip ? azurerm_public_ip.cls[count.index].id : null
    private_ip_address_allocation = "Dynamic"
  }
  tags = merge(
    local.tags,
    {
      lustre_type  = "clt",
      lustre_index = count.index
    }
  )
}

resource "azurerm_network_interface_application_security_group_association" "cls" {
  count                         = var.cls.public_ip && var.security.enable_ssh ? var.cls.node_count : 0
  network_interface_id          = azurerm_network_interface.cls[count.index].id
  application_security_group_id = azurerm_application_security_group.servers.0.id
}

resource "azurerm_network_interface_security_group_association" "cls" {
  count                     = var.cls.public_ip && var.security.enable_ssh ? var.cls.node_count : 0
  network_interface_id      = azurerm_network_interface.cls[count.index].id
  network_security_group_id = azurerm_network_security_group.servers.0.id
}

resource "azurerm_availability_set" "cls" {
  count                        = local.nodes.cls.availability ? 1 : 0
  name                         = format("%s-%s-%s", local.prefix, "cls", "availability-set")
  location                     = local.resource_group.location
  resource_group_name          = local.resource_group.name
  proximity_placement_group_id = local.proximity_placement_group.id
  platform_update_domain_count = min(var.cls.node_count, 20)
  managed                      = true
  tags                         = local.tags
}

resource "azurerm_linux_virtual_machine" "cls" {
  count                        = var.cls.node_count
  zone                         = local.zone
  size                         = var.cls.node_type
  name                         = format("%s-%s%d", local.prefix, "cls", count.index)
  location                     = local.resource_group.location
  resource_group_name          = local.resource_group.name
  proximity_placement_group_id = local.proximity_placement_group.id
  availability_set_id          = local.nodes.cls.availability ? azurerm_availability_set.cls.0.id : null
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.exa.primary_blob_endpoint
  }
  network_interface_ids = [
    azurerm_network_interface.cls[count.index].id
  ]
  os_disk {
    name                 = format("%s-%s%d-%s", local.prefix, "cls", count.index, "boot-disk")
    storage_account_type = var.boot.disk_type
    disk_size_gb         = var.boot.disk_size
    caching              = var.boot.disk_cache
  }
  plan {
    publisher = var.image.publisher
    product   = var.image.offer
    name      = var.image.sku
  }
  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }
  computer_name                   = format("%s-%s%d", local.prefix, "cls", count.index)
  disable_password_authentication = true
  admin_username                  = var.security.user_name
  admin_ssh_key {
    username   = var.security.user_name
    public_key = local.sshkey
  }
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.exa.id
    ]
  }
  tags = merge(
    local.tags,
    {
      lustre_type  = "clt",
      lustre_index = count.index
    }
  )
}

resource "azurerm_managed_disk" "clt" {
  for_each             = local.disks.clt
  zone                 = local.zone
  name                 = each.value.name
  resource_group_name  = local.resource_group.name
  location             = local.resource_group.location
  storage_account_type = each.value.type
  disk_size_gb         = each.value.size
  create_option        = "Empty"
  tags = merge(
    local.tags,
    {
      name                = each.value.name,
      lustre_target_host  = each.value.host,
      lustre_target_role  = each.value.role,
      lustre_target_index = each.value.index
    }
  )
}

resource "azurerm_virtual_machine_data_disk_attachment" "clt" {
  for_each           = local.disks.clt
  managed_disk_id    = azurerm_managed_disk.clt[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.cls[each.value.node].id
  lun                = each.value.disk
  caching            = each.value.cache
}

resource "azurerm_virtual_machine_extension" "cls" {
  count                      = var.cls.node_count
  name                       = format("%s-%s%d-%s", local.prefix, "cls", count.index, "virtual-machine-extension")
  virtual_machine_id         = azurerm_linux_virtual_machine.cls[count.index].id
  protected_settings         = local.settings
  auto_upgrade_minor_version = true
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.1"
  depends_on = [
    azurerm_role_assignment.exa,
    azurerm_app_configuration.fs_config,
    azurerm_virtual_machine_extension.mgs,
    azurerm_virtual_machine_extension.mds,
    azurerm_virtual_machine_extension.oss,
    azurerm_virtual_machine_data_disk_attachment.mgt,
    azurerm_virtual_machine_data_disk_attachment.mnt,
    azurerm_virtual_machine_data_disk_attachment.mdt,
    azurerm_virtual_machine_data_disk_attachment.ost,
    azurerm_virtual_machine_data_disk_attachment.clt
  ]
  timeouts {
    create = local.timeout
  }
  tags = merge(
    local.tags,
    {
      lustre_type  = "cls",
      lustre_index = count.index
    }
  )
}
