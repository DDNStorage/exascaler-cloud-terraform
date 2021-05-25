resource "azurerm_public_ip" "mgs" {
  count               = var.mgs.public_ip ? var.mgs.node_count : 0
  zones               = local.zones
  name                = format("%s-%s%d-%s", local.prefix, "mgs", count.index, "public-ip")
  domain_name_label   = format("%s-%s%d", local.prefix, "mgs", count.index)
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = merge(
    local.tags,
    {
      lustre_type  = "mgs",
      lustre_index = count.index
    }
  )
}

resource "azurerm_network_interface" "mgs" {
  count                         = var.mgs.node_count
  name                          = format("%s-%s%d-%s", local.prefix, "mgs", count.index, "network-interfrace")
  location                      = local.resource_group.location
  resource_group_name           = local.resource_group.name
  enable_accelerated_networking = var.mgs.accelerated_network
  ip_configuration {
    name                          = format("%s-%s%d-%s", local.prefix, "mgs", count.index, "private-ip")
    subnet_id                     = local.subnet.id
    public_ip_address_id          = var.mgs.public_ip ? azurerm_public_ip.mgs[count.index].id : null
    private_ip_address_allocation = "Dynamic"
  }
  tags = merge(
    local.tags,
    {
      lustre_type  = "mgt",
      lustre_index = count.index
    }
  )
}

resource "azurerm_network_interface_application_security_group_association" "mgs" {
  count                         = var.security.enable_ssh && var.mgs.public_ip ? var.mgs.node_count : 0
  network_interface_id          = azurerm_network_interface.mgs[count.index].id
  application_security_group_id = azurerm_application_security_group.ssh.0.id
}

resource "azurerm_network_interface_application_security_group_association" "http" {
  count                         = var.mgs.public_ip && var.security.enable_http ? var.mgs.node_count : 0
  network_interface_id          = azurerm_network_interface.mgs[count.index].id
  application_security_group_id = azurerm_application_security_group.http.0.id
}

resource "azurerm_linux_virtual_machine" "mgs" {
  count                        = var.mgs.node_count
  zone                         = local.zone
  size                         = var.mgs.node_type
  name                         = format("%s-%s%d", local.prefix, "mgs", count.index)
  location                     = local.resource_group.location
  resource_group_name          = local.resource_group.name
  proximity_placement_group_id = local.proximity_placement_group.id
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.exa.primary_blob_endpoint
  }
  network_interface_ids = [
    azurerm_network_interface.mgs[count.index].id
  ]
  os_disk {
    name                 = format("%s-%s%d-%s", local.prefix, "mgs", count.index, "boot-disk")
    storage_account_type = var.boot.disk_type
    disk_size_gb         = var.boot.disk_size
    caching              = var.boot.disk_cache
  }
  plan {
    name      = var.image.sku
    product   = var.image.offer
    publisher = var.image.publisher
  }
  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }
  custom_data                     = local.script
  computer_name                   = format("%s-%s%d", local.prefix, "mgs", count.index)
  disable_password_authentication = true
  admin_username                  = var.admin.username
  admin_ssh_key {
    username   = var.admin.username
    public_key = local.sshkey
  }
  identity {
    type = "SystemAssigned"
  }
  tags = merge(
    local.tags,
    {
      lustre_type  = "mgt",
      lustre_index = count.index
    }
  )
}

resource "azurerm_role_assignment" "mgs" {
  count                = var.mgs.node_count
  scope                = local.resource_group.id
  principal_id         = azurerm_linux_virtual_machine.mgs[count.index].identity.0.principal_id
  role_definition_name = "Contributor"
}

resource "azurerm_managed_disk" "mgt" {
  for_each             = local.disks.mgt
  zones                = local.zones
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

resource "azurerm_managed_disk" "mnt" {
  for_each             = local.disks.mnt
  zones                = local.zones
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
      lustre_target_role  = "master",
      lustre_target_index = each.value.index
    }
  )
}

resource "azurerm_virtual_machine_data_disk_attachment" "mgt" {
  for_each           = local.disks.mgt
  managed_disk_id    = azurerm_managed_disk.mgt[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.mgs[each.value.node].id
  lun                = each.value.disk
  caching            = each.value.cache
}

resource "azurerm_virtual_machine_data_disk_attachment" "mnt" {
  for_each           = local.disks.mnt
  managed_disk_id    = azurerm_managed_disk.mnt[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.mgs[each.value.node].id
  lun                = var.mgt.disk_count + each.value.disk
  caching            = each.value.cache
}
