variable "fsname" {
  type = string
}

variable "subscription" {
  type = string
}

variable "location" {
  type = string
}

variable "zone" {
  type = number
}

variable "storage_account" {
  type = object({
    replication = string
    kind        = string
    tier        = string
  })
}

variable "resource_group" {
  type = object({
    new  = bool
    name = string
  })
}

variable "proximity_placement_group" {
  type = object({
    new  = bool
    name = string
  })
}

variable "admin" {
  type = object({
    username       = string
    ssh_public_key = string
  })
}

variable "boot" {
  type = object({
    disk_type   = string
    disk_cache  = string
    disk_size   = number
    auto_delete = bool
  })
}

variable "image" {
  type = object({
    publisher = string
    version   = string
    offer     = string
    sku       = string
  })
}

variable "network" {
  type = object({
    new     = bool
    name    = string
    address = string
  })
}

variable "subnet" {
  type = object({
    new     = bool
    name    = string
    address = string
  })
}

variable "security" {
  type = object({
    enable_ssh        = bool
    ssh_source_range  = string
    enable_http       = bool
    http_source_range = string
  })
}

variable "mgs" {
  type = object({
    node_type           = string
    node_count          = number
    public_ip           = bool
    accelerated_network = bool
  })
}

variable "mgt" {
  type = object({
    disk_type  = string
    disk_cache = string
    disk_size  = number
    disk_count = number
  })
}

variable "mnt" {
  type = object({
    disk_type  = string
    disk_cache = string
    disk_size  = number
    disk_count = number
  })
}

variable "mds" {
  type = object({
    node_type           = string
    node_count          = number
    public_ip           = bool
    accelerated_network = bool
  })
}

variable "mdt" {
  type = object({
    disk_type  = string
    disk_cache = string
    disk_size  = number
    disk_count = number
  })
}

variable "oss" {
  type = object({
    node_type           = string
    node_count          = number
    public_ip           = bool
    accelerated_network = bool
  })
}

variable "ost" {
  type = object({
    disk_type  = string
    disk_cache = string
    disk_size  = number
    disk_count = number
  })
}

variable "cls" {
  type = object({
    node_type           = string
    node_count          = number
    public_ip           = bool
    accelerated_network = bool
  })
}

variable "clt" {
  type = object({
    disk_type  = string
    disk_cache = string
    disk_size  = number
    disk_count = number
  })
}
