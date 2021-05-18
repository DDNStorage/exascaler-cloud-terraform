output "private_addresses" {
  value = {
    for instance in concat(
      google_compute_instance.mgs,
      google_compute_instance.mds,
      google_compute_instance.oss,
      google_compute_instance.cls
      ) : instance.name => join(", ", flatten([
        for interface in instance.network_interface : interface.network_ip
    ]))
  }
}

output "ssh_console" {
  value = var.mgs.public_ip || var.mds.public_ip || var.oss.public_ip || var.cls.public_ip ? {
    for instance in concat(
      var.mgs.public_ip ? google_compute_instance.mgs : [],
      var.mds.public_ip ? google_compute_instance.mds : [],
      var.oss.public_ip ? google_compute_instance.oss : [],
      var.cls.public_ip ? google_compute_instance.cls : []
      ) : instance.name => join(", ", flatten([
        for interface in instance.network_interface : [
          for config in interface.access_config : format("ssh -A %s@%s", var.admin.username, config.nat_ip)
        ]
    ]))
  } : null
}

output "mount_command" {
  value = format("mount -t lustre %s:/%s /mnt/%s", join(":", flatten([
    for instance in google_compute_instance.mgs : join(":", flatten([
      for interface in instance.network_interface : format("%s@tcp", interface.network_ip)
    ]))
  ])), var.fsname, var.fsname)
}

output "web_console" {
  value = var.mgs.public_ip ? join(" ", flatten([
    for instance in google_compute_instance.mgs : flatten([
      for interface in instance.network_interface : flatten([
        for config in interface.access_config : format("http://%s", config.nat_ip)
      ])
    ])
  ])) : null
}
