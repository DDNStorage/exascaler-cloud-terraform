# Copyright (c) 2024 DataDirect Networks, Inc.
# All Rights Reserved.

variable "prefix" {
  type        = string
  default     = null
  description = "EXAScaler Cloud deployment prefix"

  validation {
    condition     = var.prefix == null ? true : can(regex("^[a-z][0-9a-z_-]{0,31}$", var.prefix))
    error_message = "The prefix value can contain only lowercase letters, numeric characters, underscores, dashes, must start with a lowercase letter and have a length of 1-32 characters."
  }
}

variable "labels" {
  type        = map(any)
  default     = {}
  description = "EXAScaler Cloud deployment labels"

  validation {
    condition     = length(var.labels) <= 64
    error_message = "The number of labels must be less than or equal to 64."
  }

  validation {
    condition = alltrue([
      for name, value in var.labels :
      can(regex("^\\p{Ll}[\\p{Ll}\\p{Nd}_-]{0,62}$", name))
    ])
    error_message = "The labels keys can contain only lowercase letters, numeric characters, underscores, dashes, must start with a lowercase letter and have a length of 1-63 characters."
  }

  validation {
    condition = alltrue([
      for name, value in var.labels :
      can(regex("^[\\p{Ll}\\p{Nd}_-]{0,63}$", value))
    ])
    error_message = "The labels values can contain only lowercase letters, numeric characters, underscores, dashes and have a length of 0-63 characters."
  }
}

variable "fsname" {
  type        = string
  default     = "exacloud"
  description = "EXAScaler Cloud filesystem name"

  validation {
    condition     = can(regex("^[0-9A-Za-z]{1,8}$", var.fsname))
    error_message = "The fsname value must be alphanumeric characters and 1-8 characters long."
  }
}

variable "project" {
  type        = string
  default     = "project-id"
  description = "Project ID to manage resources"

  validation {
    condition     = can(regex("^[a-z][0-9a-z-]{4,28}[0-9a-z]$", var.project))
    error_message = "The project ID value must be 6 to 30 characters in length."
  }
}

variable "zone" {
  type        = string
  default     = "us-central1-f"
  description = "Zone name to manage resources"

  validation {
    condition     = length(var.zone) > 0
    error_message = "The zone name value must not be empty."
  }
}

variable "service_account" {
  type = object({
    new   = bool
    email = string
  })

  default = {
    new   = false
    email = null
  }

  description = "Service account used by deploy application."

  validation {
    condition     = contains([false, true], var.service_account.new)
    error_message = "The service_account.new value must be false or true."
  }

  validation {
    condition     = var.service_account.email == null ? true : can(regex("[a-z][0-9a-z-]{4,28}[0-9a-z]@[a-z][0-9a-z-]{4,28}[0-9a-z].iam.gserviceaccount.com", var.service_account.email))
    error_message = "The service_account.email value must be a valid email address in the format: service_account_id@project_id.iam.gserviceaccount.com, service_account_id value must be 6 to 30 characters in length and project_id value must be 6 to 30 characters in length."
  }
}

variable "waiter" {
  type        = string
  default     = "deploymentmanager"
  description = "Waiter to check progress and result for deployment"

  validation {
    condition     = var.waiter == null ? true : contains(["sdk", "deploymentmanager"], var.waiter)
    error_message = "The waiter value must be deploymentmanager, sdk or null."
  }
}

variable "security" {
  type = object({
    admin              = string
    public_key         = string
    block_project_keys = bool
    enable_os_login    = bool
    enable_local       = bool
    enable_ssh         = bool
    enable_http        = bool
    ssh_source_ranges  = list(string)
    http_source_ranges = list(string)
  })

  default = {
    admin              = "stack"
    public_key         = "~/.ssh/id_rsa.pub"
    block_project_keys = false
    enable_os_login    = false
    enable_local       = true
    enable_ssh         = true
    enable_http        = true
    ssh_source_ranges = [
      "0.0.0.0/0"
    ]
    http_source_ranges = [
      "0.0.0.0/0"
    ]
  }

  description = "Security options"

  validation {
    condition     = var.security.admin == null ? true : can(regex("^[a-z][0-9a-z_-]{1,30}[0-9a-z]$", var.security.admin))
    error_message = "The security.admin value must be null or alphanumeric and must only contain letters, numbers, hyphens, and underscores and may not start with a hyphen or number."
  }

  validation {
    condition     = var.security.public_key == null ? true : fileexists(var.security.public_key)
    error_message = "The security.public_key value must be null or a path to the SSH public key."
  }

  validation {
    condition     = contains([false, true], var.security.block_project_keys)
    error_message = "The security.block_project_keys value must be false or true."
  }

  validation {
    condition     = contains([false, true], var.security.enable_os_login)
    error_message = "The security.enable_os_login value must be false or true."
  }

  validation {
    condition     = contains([false, true], var.security.enable_local)
    error_message = "The security.enable_local value must be false or true."
  }

  validation {
    condition     = contains([false, true], var.security.enable_ssh)
    error_message = "The security.enable_ssh value must be false or true."
  }

  validation {
    condition     = contains([false, true], var.security.enable_http)
    error_message = "The security.enable_http value must be false or true."
  }

  validation {
    condition = alltrue([
      for range in var.security.ssh_source_ranges :
      can(cidrhost(range, 0)) && can(cidrnetmask(range))
    ])
    error_message = "The security.ssh_source_ranges value must be a list of IP addresses in CIDR notation."
  }

  validation {
    condition = alltrue([
      for range in var.security.http_source_ranges :
      can(cidrhost(range, 0)) && can(cidrnetmask(range))
    ])
    error_message = "The security.http_source_ranges value must be a list of IP addresses in CIDR notation."
  }
}

variable "boot" {
  type = object({
    disk_type  = string
    script_url = string
  })

  default = {
    disk_type  = "pd-standard"
    script_url = null
  }

  description = "Boot options"

  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd", "pd-extreme"], var.boot.disk_type)
    error_message = "The boot.disk_type value must be pd-standard, pd-balanced, pd-ssd or pd-extreme."
  }

  validation {
    condition     = var.boot.script_url == null ? true : can(regex("^gs://[a-z][0-9a-z._-]{2,62}/[0-9a-zA-Z._-]{1,1000}$", var.boot.script_url))
    error_message = "The boot.script_url value must be a valid Google Storage URL in the format: gs://bucket_name/file_name, bucket_name value must be 3 to 63 lowercase characters in length and file_name value must be 1 to 1024 characters in length."
  }
}

variable "image" {
  type = object({
    project = string
    family  = string
  })

  default = {
    project = "ddn-public"
    family  = "exascaler-cloud-6-3-rocky-linux-8"
  }

  description = "Source image options"

  validation {
    condition     = can(regex("^[a-z][0-9a-z-]{4,28}[0-9a-z]$", var.image.project))
    error_message = "The project ID value must be 6 to 30 characters in length."
  }

  validation {
    condition     = can(regex("^[a-z][0-9a-z-]{4,61}[0-9a-z]$", var.image.family))
    error_message = "The image.family value must be alphanumeric characters and 6-63 characters long."
  }
}

variable "network" {
  type = object({
    routing = string
    tier    = string
    id      = string
    auto    = bool
    mtu     = number
    new     = bool
    nat     = bool
  })

  default = {
    routing = "REGIONAL"
    tier    = "STANDARD"
    id      = "projects/project-name/global/networks/network-name"
    auto    = false
    mtu     = 1500
    new     = true
    nat     = true
  }

  description = "Network options"

  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.network.routing)
    error_message = "The network.routing value must be REGIONAL or GLOBAL."
  }

  validation {
    condition     = contains(["STANDARD", "PREMIUM"], var.network.tier)
    error_message = "The network.tier value must be STANDARD or PREMIUM."
  }

  validation {
    condition     = length(split("/", var.network.id)) == 5
    error_message = "The network.id value must be a network id in the form projects/project-name/global/networks/network-name."
  }

  validation {
    condition     = contains([false, true], var.network.auto)
    error_message = "The network.auto value must be false or true."
  }

  validation {
    condition     = var.network.mtu >= 1460 && var.network.mtu <= 1500
    error_message = "The network.mtu value must be between 1460 and 1500."
  }

  validation {
    condition     = contains([false, true], var.network.new)
    error_message = "The network.new value must be false or true."
  }

  validation {
    condition     = contains([false, true], var.network.nat)
    error_message = "The network.nat value must be false or true."
  }
}

variable "subnetwork" {
  type = object({
    address = string
    private = bool
    id      = string
    new     = bool
  })

  default = {
    address = "10.0.0.0/24"
    private = true
    id      = "projects/project-name/regions/region-name/subnetworks/subnetwork-name"
    new     = true
  }

  description = "Subnet options"

  validation {
    condition     = can(cidrhost(var.subnetwork.address, 0)) && can(cidrnetmask(var.subnetwork.address))
    error_message = "The subnetwork.address value must be an IP address in CIDR notation."
  }

  validation {
    condition     = contains([false, true], var.subnetwork.private)
    error_message = "The subnetwork.private value must be false or true."
  }

  validation {
    condition     = length(split("/", var.subnetwork.id)) == 6
    error_message = "The subnetwork.id value must be a subnetwork id in the form projects/project-name/regions/region-name/subnetworks/subnetwork-name."
  }

  validation {
    condition     = contains([false, true], var.subnetwork.new)
    error_message = "The subnetwork.new value must be false or true."
  }
}

variable "mgs" {
  type = object({
    node_type  = string
    node_cpu   = string
    nic_type   = string
    public_ip  = bool
    node_count = number
  })

  default = {
    node_type  = "n2-standard-2"
    node_cpu   = "Intel Cascade Lake"
    nic_type   = "GVNIC"
    public_ip  = true
    node_count = 1
  }

  description = "Management server options"

  validation {
    condition     = length(var.mgs.node_type) > 0
    error_message = "The mgs.node_type value must not be empty."
  }

  validation {
    condition     = length(var.mgs.node_cpu) > 0
    error_message = "The mgs.node_cpu value must not be empty."
  }

  validation {
    condition     = contains(["GVNIC", "VIRTIO_NET"], var.mgs.nic_type)
    error_message = "The mgs.nic_type value must be GVNIC or VIRTIO_NET."
  }

  validation {
    condition     = contains([false, true], var.mgs.public_ip)
    error_message = "The mgs.public_ip value must be false or true."
  }

  validation {
    condition     = var.mgs.node_count == 1
    error_message = "The mgs.node_count value must be 1."
  }

  validation {
    condition     = abs(var.mgs.node_count) == var.mgs.node_count
    error_message = "The mgs.node_count value must be a positive."
  }

  validation {
    condition     = floor(var.mgs.node_count) == ceil(var.mgs.node_count)
    error_message = "The mgs.node_count value must be an integer."
  }
}

variable "mgt" {
  type = object({
    disk_bus   = string
    disk_type  = string
    disk_iops  = number
    disk_mbps  = number
    disk_size  = number
    disk_count = number
    disk_raid  = bool
  })

  default = {
    disk_bus   = "SCSI"
    disk_type  = "pd-standard"
    disk_iops  = null
    disk_mbps  = null
    disk_size  = 128
    disk_count = 1
    disk_raid  = false
  }

  description = "Management target options"

  validation {
    condition     = contains(["SCSI", "NVME"], var.mgt.disk_bus)
    error_message = "The mgt.disk_bus value must be SCSI or NVME."
  }

  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd", "pd-extreme", "hyperdisk-balanced", "hyperdisk-extreme", "hyperdisk-throughput", "scratch"], var.mgt.disk_type)
    error_message = "The mgt.disk_type value must be pd-standard, pd-balanced, pd-ssd, pd-extreme, hyperdisk-balanced, hyperdisk-extreme, hyperdisk-throughput or scratch."
  }

  validation {
    condition     = var.mgt.disk_size >= 4 && var.mgt.disk_size <= 65536
    error_message = "The mgt.disk_size value must be between 4 and 65536."
  }

  validation {
    condition     = abs(var.mgt.disk_size) == var.mgt.disk_size
    error_message = "The mgt.disk_size value must be a positive."
  }

  validation {
    condition     = floor(var.mgt.disk_size) == ceil(var.mgt.disk_size)
    error_message = "The mgt.disk_size value must be an integer."
  }

  validation {
    condition     = var.mgt.disk_count > 0 && var.mgt.disk_count <= 128
    error_message = "The mgt.disk_count value must be between 1 and 128."
  }

  validation {
    condition     = abs(var.mgt.disk_count) == var.mgt.disk_count
    error_message = "The mgt.disk_count value must be a positive."
  }

  validation {
    condition     = floor(var.mgt.disk_count) == ceil(var.mgt.disk_count)
    error_message = "The mgt.disk_count value must be an integer."
  }

  validation {
    condition     = contains([false, true], var.mgt.disk_raid)
    error_message = "The mgt.disk_raid value must be false or true."
  }
}

variable "mnt" {
  type = object({
    disk_bus   = string
    disk_type  = string
    disk_iops  = number
    disk_mbps  = number
    disk_size  = number
    disk_count = number
    disk_raid  = bool
  })

  default = {
    disk_bus   = "SCSI"
    disk_type  = "pd-standard"
    disk_iops  = null
    disk_mbps  = null
    disk_size  = 128
    disk_count = 1
    disk_raid  = false
  }

  description = "Monitoring target options"

  validation {
    condition     = contains(["SCSI", "NVME"], var.mnt.disk_bus)
    error_message = "The mnt.disk_bus value must be SCSI or NVME."
  }

  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd", "pd-extreme", "hyperdisk-balanced", "hyperdisk-extreme", "hyperdisk-throughput", "scratch"], var.mnt.disk_type)
    error_message = "The mnt.disk_type value must be pd-standard, pd-balanced, pd-ssd, pd-extreme, hyperdisk-balanced, hyperdisk-extreme, hyperdisk-throughput or scratch."
  }

  validation {
    condition     = var.mnt.disk_size >= 4 && var.mnt.disk_size <= 65536
    error_message = "The mnt.disk_size value must be between 4 and 65536."
  }

  validation {
    condition     = abs(var.mnt.disk_size) == var.mnt.disk_size
    error_message = "The mnt.disk_size value must be a positive."
  }

  validation {
    condition     = floor(var.mnt.disk_size) == ceil(var.mnt.disk_size)
    error_message = "The mnt.disk_size value must be an integer."
  }

  validation {
    condition     = var.mnt.disk_count > 0 && var.mnt.disk_count <= 128
    error_message = "The mnt.disk_count value must be between 1 and 128."
  }

  validation {
    condition     = abs(var.mnt.disk_count) == var.mnt.disk_count
    error_message = "The mnt.disk_count value must be a positive."
  }

  validation {
    condition     = floor(var.mnt.disk_count) == ceil(var.mnt.disk_count)
    error_message = "The mnt.disk_count value must be an integer."
  }

  validation {
    condition     = contains([false, true], var.mnt.disk_raid)
    error_message = "The mnt.disk_raid value must be false or true."
  }
}

variable "mds" {
  type = object({
    node_type  = string
    node_cpu   = string
    nic_type   = string
    public_ip  = bool
    node_count = number
  })

  default = {
    node_type  = "n2-standard-2"
    node_cpu   = "Intel Cascade Lake"
    nic_type   = "GVNIC"
    public_ip  = false
    node_count = 1
  }

  description = "Metadata server options"

  validation {
    condition     = length(var.mds.node_type) > 0
    error_message = "The mds.node_type value must not be empty."
  }

  validation {
    condition     = length(var.mds.node_cpu) > 0
    error_message = "The mds.node_cpu value must not be empty."
  }

  validation {
    condition     = contains(["GVNIC", "VIRTIO_NET"], var.mds.nic_type)
    error_message = "The mds.nic_type value must be GVNIC or VIRTIO_NET."
  }

  validation {
    condition     = contains([false, true], var.mds.public_ip)
    error_message = "The mds.public_ip value must be false or true."
  }

  validation {
    condition     = var.mds.node_count >= 1 && var.mds.node_count <= 32
    error_message = "The mds.node_count value must be between 1 and 32."
  }

  validation {
    condition     = abs(var.mds.node_count) == var.mds.node_count
    error_message = "The mds.node_count value must be a positive."
  }

  validation {
    condition     = floor(var.mds.node_count) == ceil(var.mds.node_count)
    error_message = "The mds.node_count value must be an integer."
  }
}

variable "mdt" {
  type = object({
    disk_bus   = string
    disk_type  = string
    disk_iops  = number
    disk_mbps  = number
    disk_size  = number
    disk_count = number
    disk_raid  = bool
  })

  default = {
    disk_bus   = "SCSI"
    disk_type  = "pd-ssd"
    disk_iops  = null
    disk_mbps  = null
    disk_size  = 256
    disk_count = 1
    disk_raid  = false
  }

  description = "Metadata target options"

  validation {
    condition     = contains(["SCSI", "NVME"], var.mdt.disk_bus)
    error_message = "The mdt.disk_bus value must be SCSI or NVME."
  }

  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd", "pd-extreme", "hyperdisk-balanced", "hyperdisk-extreme", "hyperdisk-throughput", "scratch"], var.mdt.disk_type)
    error_message = "The mdt.disk_type value must be pd-standard, pd-balanced, pd-ssd, pd-extreme, hyperdisk-balanced, hyperdisk-extreme, hyperdisk-throughput or scratch."
  }

  validation {
    condition     = var.mdt.disk_size >= 4 && var.mdt.disk_size <= 65536
    error_message = "The mdt.disk_size value must be between 4 and 65536."
  }

  validation {
    condition     = abs(var.mdt.disk_size) == var.mdt.disk_size
    error_message = "The mdt.disk_size value must be a positive."
  }

  validation {
    condition     = floor(var.mdt.disk_size) == ceil(var.mdt.disk_size)
    error_message = "The mdt.disk_size value must be an integer."
  }

  validation {
    condition     = var.mdt.disk_count > 0 && var.mdt.disk_count <= 128
    error_message = "The mdt.disk_count value must be between 1 and 128."
  }

  validation {
    condition     = abs(var.mdt.disk_count) == var.mdt.disk_count
    error_message = "The mdt.disk_count value must be a positive."
  }

  validation {
    condition     = floor(var.mdt.disk_count) == ceil(var.mdt.disk_count)
    error_message = "The mdt.disk_count value must be an integer."
  }

  validation {
    condition     = contains([false, true], var.mdt.disk_raid)
    error_message = "The mdt.disk_raid value must be false or true."
  }
}

variable "oss" {
  type = object({
    node_type  = string
    node_cpu   = string
    nic_type   = string
    public_ip  = bool
    node_count = number
  })

  default = {
    node_type  = "n2-standard-2"
    node_cpu   = "Intel Cascade Lake"
    nic_type   = "GVNIC"
    public_ip  = false
    node_count = 1
  }

  description = "Storage server options"

  validation {
    condition     = length(var.oss.node_type) > 0
    error_message = "The oss.node_type value must not be empty."
  }

  validation {
    condition     = length(var.oss.node_cpu) > 0
    error_message = "The oss.node_cpu value must not be empty."
  }

  validation {
    condition     = contains(["GVNIC", "VIRTIO_NET"], var.oss.nic_type)
    error_message = "The oss.nic_type value must be GVNIC or VIRTIO_NET."
  }

  validation {
    condition     = contains([false, true], var.oss.public_ip)
    error_message = "The oss.public_ip value must be false or true."
  }

  validation {
    condition     = var.oss.node_count >= 1 && var.oss.node_count <= 2000
    error_message = "The oss.node_count value must be between 1 and 2000."
  }

  validation {
    condition     = abs(var.oss.node_count) == var.oss.node_count
    error_message = "The oss.node_count value must be a positive."
  }

  validation {
    condition     = floor(var.oss.node_count) == ceil(var.oss.node_count)
    error_message = "The oss.node_count value must be an integer."
  }
}

variable "ost" {
  type = object({
    disk_bus   = string
    disk_type  = string
    disk_iops  = number
    disk_mbps  = number
    disk_size  = number
    disk_count = number
    disk_raid  = bool
  })

  default = {
    disk_bus   = "SCSI"
    disk_type  = "pd-standard"
    disk_iops  = null
    disk_mbps  = null
    disk_size  = 512
    disk_count = 1
    disk_raid  = false
  }

  description = "Storage target options"

  validation {
    condition     = contains(["SCSI", "NVME"], var.ost.disk_bus)
    error_message = "The ost.disk_bus value must be SCSI or NVME."
  }

  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd", "pd-extreme", "hyperdisk-balanced", "hyperdisk-extreme", "hyperdisk-throughput", "scratch"], var.ost.disk_type)
    error_message = "The ost.disk_type value must be pd-standard, pd-balanced, pd-ssd, pd-extreme, hyperdisk-balanced, hyperdisk-extreme, hyperdisk-throughput or scratch."
  }

  validation {
    condition     = var.ost.disk_size >= 4 && var.ost.disk_size <= 65536
    error_message = "The ost.disk_size value must be between 4 and 65536."
  }

  validation {
    condition     = abs(var.ost.disk_size) == var.ost.disk_size
    error_message = "The ost.disk_size value must be a positive."
  }

  validation {
    condition     = floor(var.ost.disk_size) == ceil(var.ost.disk_size)
    error_message = "The ost.disk_size value must be an integer."
  }

  validation {
    condition     = var.ost.disk_count > 0 && var.ost.disk_count <= 128
    error_message = "The ost.disk_count value must be between 1 and 128."
  }

  validation {
    condition     = abs(var.ost.disk_count) == var.ost.disk_count
    error_message = "The ost.disk_count value must be a positive."
  }

  validation {
    condition     = floor(var.ost.disk_count) == ceil(var.ost.disk_count)
    error_message = "The ost.disk_count value must be an integer."
  }

  validation {
    condition     = contains([false, true], var.ost.disk_raid)
    error_message = "The ost.disk_raid value must be false or true."
  }
}

variable "cls" {
  type = object({
    node_type  = string
    node_cpu   = string
    nic_type   = string
    public_ip  = bool
    node_count = number
  })

  default = {
    node_type  = "n2-standard-2"
    node_cpu   = "Intel Cascade Lake"
    nic_type   = "GVNIC"
    public_ip  = false
    node_count = 1
  }

  description = "Compute client options"

  validation {
    condition     = length(var.cls.node_type) > 0
    error_message = "The cls.node_type value must not be empty."
  }

  validation {
    condition     = length(var.cls.node_cpu) > 0
    error_message = "The cls.node_cpu value must not be empty."
  }

  validation {
    condition     = contains(["GVNIC", "VIRTIO_NET"], var.cls.nic_type)
    error_message = "The cls.nic_type value must be GVNIC or VIRTIO_NET."
  }

  validation {
    condition     = contains([false, true], var.cls.public_ip)
    error_message = "The cls.public_ip value must be false or true."
  }

  validation {
    condition     = var.cls.node_count >= 0
    error_message = "The cls.node_count value must be a positive."
  }

  validation {
    condition     = abs(var.cls.node_count) == var.cls.node_count
    error_message = "The cls.node_count value must be a positive."
  }

  validation {
    condition     = floor(var.cls.node_count) == ceil(var.cls.node_count)
    error_message = "The cls.node_count value must be an integer."
  }
}

variable "clt" {
  type = object({
    disk_bus   = string
    disk_type  = string
    disk_iops  = number
    disk_mbps  = number
    disk_size  = number
    disk_count = number
  })

  default = {
    disk_bus   = "SCSI"
    disk_type  = "pd-standard"
    disk_iops  = null
    disk_mbps  = null
    disk_size  = 256
    disk_count = 0
  }

  description = "Compute target options"

  validation {
    condition     = contains(["SCSI", "NVME"], var.clt.disk_bus)
    error_message = "The clt.disk_bus value must be SCSI or NVME."
  }

  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd", "pd-extreme", "hyperdisk-balanced", "hyperdisk-extreme", "hyperdisk-throughput", "scratch"], var.clt.disk_type)
    error_message = "The clt.disk_type value must be pd-standard, pd-balanced, pd-ssd, pd-extreme, hyperdisk-balanced, hyperdisk-extreme, hyperdisk-throughput or scratch."
  }

  validation {
    condition     = var.clt.disk_size >= 4 && var.clt.disk_size <= 65536
    error_message = "The clt.disk_size value must be between 4 and 65536."
  }

  validation {
    condition     = abs(var.clt.disk_size) == var.clt.disk_size
    error_message = "The clt.disk_size value must be a positive."
  }

  validation {
    condition     = floor(var.clt.disk_size) == ceil(var.clt.disk_size)
    error_message = "The clt.disk_size value must be an integer."
  }

  validation {
    condition     = var.clt.disk_count >= 0 && var.clt.disk_count <= 128
    error_message = "The clt.disk_count value must be between 0 and 128."
  }

  validation {
    condition     = abs(var.clt.disk_count) == var.clt.disk_count
    error_message = "The clt.disk_count value must be a positive."
  }

  validation {
    condition     = floor(var.clt.disk_count) == ceil(var.clt.disk_count)
    error_message = "The clt.disk_count value must be an integer."
  }
}
