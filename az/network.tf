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

resource "azurerm_network_security_group" "exa" {
  name                = format("%s-%s", local.prefix, "network-security-group")
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  tags                = local.tags
}

resource "azurerm_application_security_group" "http" {
  count               = var.security.enable_http ? 1 : 0
  name                = format("%s-%s", local.prefix, "http-application-security-group")
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  tags                = local.tags
}

resource "azurerm_application_security_group" "ssh" {
  count               = var.security.enable_ssh ? 1 : 0
  name                = format("%s-%s", local.prefix, "ssh-application-security-group")
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "http" {
  count                  = var.security.enable_http ? 1 : 0
  name                   = format("%s-%s", local.prefix, "network-security-rule-allow-http")
  priority               = 100
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = "80"
  source_address_prefixes = [
    var.security.http_source_range
  ]
  destination_application_security_group_ids = [
    azurerm_application_security_group.http.0.id
  ]
  resource_group_name         = local.resource_group.name
  network_security_group_name = azurerm_network_security_group.exa.name
}

resource "azurerm_network_security_rule" "ssh" {
  count                  = var.security.enable_ssh ? 1 : 0
  name                   = format("%s-%s", local.prefix, "network-security-rule-allow-ssh")
  priority               = 200
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = "22"
  source_address_prefixes = [
    var.security.ssh_source_range
  ]
  destination_application_security_group_ids = [
    azurerm_application_security_group.ssh.0.id
  ]
  resource_group_name         = local.resource_group.name
  network_security_group_name = azurerm_network_security_group.exa.name
}

resource "azurerm_subnet_network_security_group_association" "exa" {
  count                     = var.subnet.new ? 1 : 0
  subnet_id                 = local.subnet.id
  network_security_group_id = azurerm_network_security_group.exa.id
}
