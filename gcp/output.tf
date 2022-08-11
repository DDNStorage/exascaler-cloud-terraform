output "private_addresses" {
  value = {
    for host in concat(
      google_compute_address.mgs_int,
      google_compute_address.mds_int,
      google_compute_address.oss_int,
      google_compute_address.cls_int
    ) : host.description => host.address
  }
}

output "ssh_console" {
  value = var.security.admin != null && var.security.enable_ssh ? {
    for host in concat(
      var.mgs.public_ip ? google_compute_address.mgs_ext : [],
      var.mds.public_ip ? google_compute_address.mds_ext : [],
      var.oss.public_ip ? google_compute_address.oss_ext : [],
      var.cls.public_ip ? google_compute_address.cls_ext : []
    ) : host.description => format("ssh -A %s@%s", var.security.admin, host.address)
  } : null
}

output "mount_command" {
  value = format("mount -t lustre %s:/%s /mnt/%s", join(":", flatten([
    for host in google_compute_address.mgs_int : format("%s@tcp", host.address)
  ])), var.fsname, var.fsname)
}

output "http_console" {
  value = var.mgs.public_ip && var.security.enable_http ? join(" ",
    [
      for address in google_compute_address.mgs_ext : format("http://%s", address.address)
    ]
  ) : null
}

output "client_config" {
  value = local.client
}
