variable "fsname" {
  type = string
}

variable "project" {
  type = string
}

variable "service_account" {
  type = string
}

variable "credentials" {
  type = string
}

variable "zone" {
  type = string
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
    auto_delete = bool
  })
}

variable "image" {
  type = object({
    project = string
    name    = string
  })
}

variable "network" {
  type = object({
    routing = string
    tier    = string
    name    = string
    auto    = bool
    mtu     = number
    new     = bool
    nat     = bool
  })
}

variable "subnetwork" {
  type = object({
    address = string
    private = bool
    name    = string
    new     = bool
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
    node_type  = string
    node_cpu   = string
    nic_type   = string
    node_count = number
    public_ip  = bool
  })
}

variable "mgt" {
  type = object({
    disk_bus   = string
    disk_type  = string
    disk_size  = number
    disk_count = number
  })
}

variable "mnt" {
  type = object({
    disk_bus   = string
    disk_type  = string
    disk_size  = number
    disk_count = number
  })
}

variable "mds" {
  type = object({
    node_type  = string
    node_cpu   = string
    nic_type   = string
    node_count = number
    public_ip  = bool
  })
}

variable "mdt" {
  type = object({
    disk_bus   = string
    disk_type  = string
    disk_size  = number
    disk_count = number
  })
}

variable "oss" {
  type = object({
    node_type  = string
    node_cpu   = string
    nic_type   = string
    node_count = number
    public_ip  = bool
  })
}

variable "ost" {
  type = object({
    disk_bus   = string
    disk_type  = string
    disk_size  = number
    disk_count = number
  })
}

variable "cls" {
  type = object({
    node_type  = string
    node_cpu   = string
    nic_type   = string
    node_count = number
    public_ip  = bool
  })
}

variable "clt" {
  type = object({
    disk_bus   = string
    disk_type  = string
    disk_size  = number
    disk_count = number
  })
}
