resource "azurerm_public_ip" "mds" {
  count               = var.mds.public_ip ? var.mds.node_count : 0
  name                = format("%s-%s%d-%s", local.prefix, "mds", count.index, "public-ip")
  domain_name_label   = format("%s-%s%d", local.prefix, "mds", count.index)
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  zones               = local.zones
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = merge(
    local.tags,
    {
      lustre_type  = "mds",
      lustre_index = count.index
    }
  )
}

resource "azurerm_network_interface" "mds" {
  count                         = var.mds.node_count
  name                          = format("%s-%s%d-%s", local.prefix, "mds", count.index, "network-interface")
  location                      = local.resource_group.location
  resource_group_name           = local.resource_group.name
  enable_accelerated_networking = var.mds.accelerated_network
  ip_configuration {
    name                          = format("%s-%s%d-%s", local.prefix, "mds", count.index, "private-ip")
    subnet_id                     = local.subnet.id
    public_ip_address_id          = var.mds.public_ip ? azurerm_public_ip.mds[count.index].id : null
    private_ip_address_allocation = "Dynamic"
  }
  tags = merge(
    local.tags,
    {
      lustre_type  = "mdt",
      lustre_index = count.index
    }
  )
}

resource "azurerm_network_interface_application_security_group_association" "mds" {
  count                         = var.mds.public_ip && var.security.enable_ssh ? var.mds.node_count : 0
  network_interface_id          = azurerm_network_interface.mds[count.index].id
  application_security_group_id = azurerm_application_security_group.servers.0.id
}

resource "azurerm_network_interface_security_group_association" "mds" {
  count                     = var.mds.public_ip && var.security.enable_ssh ? var.mds.node_count : 0
  network_interface_id      = azurerm_network_interface.mds[count.index].id
  network_security_group_id = azurerm_network_security_group.servers.0.id
}

resource "azurerm_availability_set" "mds" {
  count                        = local.nodes.mds.availability ? 1 : 0
  name                         = format("%s-%s-%s", local.prefix, "mds", "availability-set")
  location                     = local.resource_group.location
  resource_group_name          = local.resource_group.name
  proximity_placement_group_id = local.proximity_placement_group.id
  platform_update_domain_count = min(var.mds.node_count, 20)
  managed                      = true
  tags                         = local.tags
}

resource "azurerm_linux_virtual_machine" "mds" {
  count                        = var.mds.node_count
  zone                         = local.zone
  size                         = var.mds.node_type
  name                         = format("%s-%s%d", local.prefix, "mds", count.index)
  location                     = local.resource_group.location
  resource_group_name          = local.resource_group.name
  proximity_placement_group_id = local.proximity_placement_group.id
  availability_set_id          = local.nodes.mds.availability ? azurerm_availability_set.mds.0.id : null
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.exa.primary_blob_endpoint
  }
  network_interface_ids = [
    azurerm_network_interface.mds[count.index].id
  ]
  os_disk {
    name                 = format("%s-%s%d-%s", local.prefix, "mds", count.index, "boot-disk")
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
  computer_name                   = format("%s-%s%d", local.prefix, "mds", count.index)
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
      lustre_type  = "mdt",
      lustre_index = count.index
    }
  )
}

resource "azurerm_managed_disk" "mdt" {
  for_each             = local.disks.mdt
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

resource "azurerm_virtual_machine_data_disk_attachment" "mdt" {
  for_each           = local.disks.mdt
  managed_disk_id    = azurerm_managed_disk.mdt[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.mds[each.value.node].id
  lun                = each.value.disk
  caching            = each.value.cache
}

resource "azurerm_virtual_machine_extension" "mds" {
  count                      = var.mds.node_count
  name                       = format("%s-%s%d-%s", local.prefix, "mds", count.index, "virtual-machine-extension")
  virtual_machine_id         = azurerm_linux_virtual_machine.mds[count.index].id
  protected_settings         = local.settings
  auto_upgrade_minor_version = true
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.1"
  depends_on = [
    azurerm_role_assignment.exa,
    azurerm_app_configuration.fs_config,
    azurerm_virtual_machine_data_disk_attachment.mgt,
    azurerm_virtual_machine_data_disk_attachment.mnt,
    azurerm_virtual_machine_data_disk_attachment.mdt,
    azurerm_virtual_machine_data_disk_attachment.ost
  ]
  timeouts {
    create = local.timeout
  }
  tags = merge(
    local.tags,
    {
      lustre_type  = "mds",
      lustre_index = count.index
    }
  )
}
