output "private_addresses" {
  value = {
    for nic in concat(
      azurerm_network_interface.mgs,
      azurerm_network_interface.mds,
      azurerm_network_interface.oss,
      azurerm_network_interface.cls,
    ) : replace(nic.name, "-network-interfrace", "") => nic.private_ip_address
  }
}

output "ssh_console" {
  value = var.mgs.public_ip || var.mds.public_ip || var.oss.public_ip || var.cls.public_ip ? {
    for pip in concat(
      var.mgs.public_ip ? azurerm_public_ip.mgs : [],
      var.mds.public_ip ? azurerm_public_ip.mds : [],
      var.oss.public_ip ? azurerm_public_ip.oss : [],
      var.cls.public_ip ? azurerm_public_ip.cls : []
    ) : pip.domain_name_label => format("ssh -A %s@%s", var.admin.username, pip.fqdn)
  } : null
}

output "mount_command" {
  value = format("mount -t lustre %s:/%s /mnt/%s", join(":", flatten([
    for nic in azurerm_network_interface.mgs : join(":", flatten([
      format("%s@tcp", nic.private_ip_address)
    ]))
  ])), var.fsname, var.fsname)
}

output "web_console" {
  value = var.mgs.public_ip ? format("http://%s", join(":", flatten([
    for pip in azurerm_public_ip.mgs : join(":", flatten([
      pip.fqdn
    ]))
  ]))) : null
}
