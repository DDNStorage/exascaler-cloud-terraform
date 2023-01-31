# Copyright (c) 2023 DataDirect Networks, Inc.
# All Rights Reserved.

data "azurerm_virtual_network" "exa" {
  count               = var.network.new ? 0 : 1
  resource_group_name = local.resource_group.name
  name                = var.network.name
}

data "azurerm_subnet" "exa" {
  count                = var.subnet.new ? 0 : 1
  resource_group_name  = local.resource_group.name
  virtual_network_name = local.network.name
  name                 = var.subnet.name
}

resource "azurerm_virtual_network" "exa" {
  count               = var.network.new ? 1 : 0
  name                = format("%s-%s", local.prefix, "virtual-network")
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  address_space = [
    var.network.address
  ]
  tags = local.tags
}

resource "azurerm_subnet" "exa" {
  count                = var.subnet.new ? 1 : 0
  name                 = format("%s-%s", local.prefix, "subnet")
  resource_group_name  = local.resource_group.name
  virtual_network_name = local.network.name
  address_prefixes = [
    var.subnet.address
  ]
}

resource "azurerm_network_security_group" "management" {
  count               = var.mgs.public_ip && (var.security.enable_ssh || var.security.enable_http) ? 1 : 0
  name                = format("%s-%s", local.prefix, "management-network-security-group")
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  tags                = local.tags
}

resource "azurerm_network_security_group" "servers" {
  count               = (var.mds.public_ip || var.oss.public_ip || var.cls.public_ip) && var.security.enable_ssh ? 1 : 0
  name                = format("%s-%s", local.prefix, "servers-network-security-group")
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  tags                = local.tags
}

resource "azurerm_application_security_group" "management" {
  count               = var.mgs.public_ip && (var.security.enable_ssh || var.security.enable_http) ? 1 : 0
  name                = format("%s-%s", local.prefix, "management-application-security-group")
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  tags                = local.tags
}

resource "azurerm_application_security_group" "servers" {
  count               = (var.mds.public_ip || var.oss.public_ip || var.cls.public_ip) && var.security.enable_ssh ? 1 : 0
  name                = format("%s-%s", local.prefix, "servers-application-security-group")
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "management_ssh" {
  count                   = var.mgs.public_ip && var.security.enable_ssh ? 1 : 0
  name                    = format("%s-%s", local.prefix, "ssh-network-security-rule")
  description             = "Allow remote SSH access to the management server"
  priority                = 100
  direction               = "Inbound"
  access                  = "Allow"
  protocol                = "Tcp"
  source_port_range       = "*"
  destination_port_range  = "22"
  source_address_prefixes = var.security.ssh_source_ranges
  destination_application_security_group_ids = [
    azurerm_application_security_group.management.0.id
  ]
  resource_group_name         = local.resource_group.name
  network_security_group_name = azurerm_network_security_group.management.0.name
}

resource "azurerm_network_security_rule" "management_http" {
  count                   = var.mgs.public_ip && var.security.enable_http ? 1 : 0
  name                    = format("%s-%s", local.prefix, "http-network-security-rule")
  description             = "Allow remote HTTP access to the management server"
  priority                = 300
  direction               = "Inbound"
  access                  = "Allow"
  protocol                = "Tcp"
  source_port_range       = "*"
  destination_port_range  = "80"
  source_address_prefixes = var.security.http_source_ranges
  destination_application_security_group_ids = [
    azurerm_application_security_group.management.0.id
  ]
  resource_group_name         = local.resource_group.name
  network_security_group_name = azurerm_network_security_group.management.0.name
}

resource "azurerm_network_security_rule" "servers_ssh" {
  count                   = (var.mds.public_ip || var.oss.public_ip || var.cls.public_ip) && var.security.enable_ssh ? 1 : 0
  name                    = format("%s-%s", local.prefix, "ssh-network-security-rule")
  description             = "Allow remote SSH access to all servers"
  priority                = 200
  direction               = "Inbound"
  access                  = "Allow"
  protocol                = "Tcp"
  source_port_range       = "*"
  destination_port_range  = "22"
  source_address_prefixes = var.security.ssh_source_ranges
  destination_application_security_group_ids = [
    azurerm_application_security_group.servers.0.id
  ]
  resource_group_name         = local.resource_group.name
  network_security_group_name = azurerm_network_security_group.servers.0.name
}
