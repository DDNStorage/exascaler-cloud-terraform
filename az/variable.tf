variable "profile" {
  type        = string
  default     = "custom"
  description = "Configuration profile name"

  validation {
    condition     = contains(["custom", "small", "medium"], var.profile)
    error_message = "The profile value should be custom, small or medium."
  }
}

variable "fsname" {
  type        = string
  default     = "exacloud"
  description = "EXAScaler filesystem name"

  validation {
    condition     = can(regex("^[0-9A-Za-z]{1,8}$", var.fsname))
    error_message = "The fsname value should be alphanumeric characters and 1-8 characters long."
  }
}

variable "subscription" {
  type        = string
  description = "Subscription ID"

  validation {
    condition     = can(uuidv5(var.subscription, var.subscription))
    error_message = "The subscription value should be a 32-digit GUID."
  }
}

variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region to manage resources"

  validation {
    condition     = length(var.location) > 0
    error_message = "The location value must not be empty."
  }
}

variable "availability" {
  type = object({
    type = string
    zone = number
  })

  default = {
    type = "none"
    zone = 1
  }

  description = "Availability options"

  validation {
    condition     = contains(["none", "set", "zone"], var.availability.type)
    error_message = "The availability.type value should be none, set or zone."
  }

  validation {
    condition     = contains([1, 2, 3], var.availability.zone)
    error_message = "The availability.zone value should be 1, 2 or 3."
  }
}

variable "storage_account" {
  type = object({
    kind        = string
    tier        = string
    replication = string
  })

  default = {
    kind        = "StorageV2"
    tier        = "Standard"
    replication = "LRS"
  }

  description = "Storage account options"

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.storage_account.kind)
    error_message = "The storage_account.kind value should be BlobStorage, BlockBlobStorage, FileStorage, Storage or StorageV2."
  }

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account.tier)
    error_message = "The storage_account.tier value should be Standard or Premium."
  }

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account.replication)
    error_message = "The storage_account.replication value should be LRS, GRS, RAGRS, ZRS, GZRS or RAGZRS."
  }
}

variable "resource_group" {
  type = object({
    new  = bool
    name = string
  })

  default = {
    new  = true
    name = "existing-resource-group"
  }

  description = "Resource group options"

  validation {
    condition     = contains([false, true], var.resource_group.new)
    error_message = "The resource_group.new value should be false or true."
  }

  validation {
    condition     = can(regex("^[0-9A-Za-z_-]{1,64}$", var.resource_group.name))
    error_message = "The resource_group.name value should be alphanumeric characters and 1-64 characters long."
  }
}

variable "proximity_placement_group" {
  type = object({
    new  = bool
    name = string
  })

  default = {
    new  = true
    name = "existing-proximity-placement-group"
  }

  description = "Proximity placement group options"

  validation {
    condition     = contains([false, true], var.proximity_placement_group.new)
    error_message = "The proximity_placement_group.new value should be false or true."
  }

  validation {
    condition     = can(regex("^[0-9A-Za-z_-]{1,64}$", var.proximity_placement_group.name))
    error_message = "The proximity_placement_group.name value should be alphanumeric characters and 1-64 characters long."
  }
}

variable "admin" {
  type = object({
    username       = string
    ssh_public_key = string
  })

  description = "Authentication options for remote SSH access"

  validation {
    condition     = can(regex("^[a-z][0-9a-z_-]{1,32}$", var.admin.username))
    error_message = "The admin.username value should be alphanumeric and must only contain letters, numbers, hyphens, and underscores and may not start with a hyphen or number."
  }

  validation {
    condition     = fileexists(var.admin.ssh_public_key)
    error_message = "The admin.ssh_public_key value should be a path to the SSH public key."
  }
}

variable "boot" {
  type = object({
    disk_type   = string
    disk_cache  = string
    disk_size   = number
    auto_delete = bool
  })

  default = {
    disk_type   = "StandardSSD_LRS"
    disk_cache  = "ReadWrite"
    disk_size   = 64
    auto_delete = true
  }

  description = "Boot disk options"

  validation {
    condition     = contains(["Standard_LRS", "Premium_LRS", "StandardSSD_LRS"], var.boot.disk_type)
    error_message = "The boot.disk_type value should be Standard_LRS, Premium_LRS or StandardSSD_LRS."
  }

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.boot.disk_cache)
    error_message = "The boot.disk_cache value should be None, ReadOnly or ReadWrite."
  }

  validation {
    condition     = var.boot.disk_size > 63 && var.boot.disk_size < 4096
    error_message = "The boot.disk_size value should be between 64 and 4095."
  }

  validation {
    condition     = abs(var.boot.disk_size) == var.boot.disk_size
    error_message = "The boot.disk_size value should be a positive."
  }

  validation {
    condition     = floor(var.boot.disk_size) == ceil(var.boot.disk_size)
    error_message = "The boot.disk_size value should be an integer."
  }

  validation {
    condition     = contains([false, true], var.boot.auto_delete)
    error_message = "The boot.auto_delete value should be false or true."
  }
}

variable "image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
    accept    = bool
  })

  default = {
    publisher = "ddn-whamcloud-5345716"
    offer     = "exascaler_cloud"
    sku       = "exascaler_cloud_523_centos"
    version   = "5.2.3"
    accept    = false
  }

  description = "Source image options"

  validation {
    condition     = contains(["ddn-whamcloud-5345716"], var.image.publisher)
    error_message = "The image.publisher value should be ddn-whamcloud-5345716."
  }

  validation {
    condition     = contains(["exascaler_cloud"], var.image.offer)
    error_message = "The image.offer value should be exascaler_cloud."
  }

  validation {
    condition     = contains(["exascaler_cloud_523_centos", "exascaler_cloud_523_redhat"], var.image.sku)
    error_message = "The image.sku value should be exascaler_cloud_523_centos or exascaler_cloud_523_redhat."
  }

  validation {
    condition     = contains(["5.2.3"], var.image.version)
    error_message = "The image.version value should be 5.2.3."
  }

  validation {
    condition     = contains([false, true], var.image.accept)
    error_message = "The image.accept value should be false or true."
  }
}

variable "network" {
  type = object({
    new     = bool
    name    = string
    address = string
  })

  default = {
    new     = true
    name    = "existing-network"
    address = "10.0.0.0/8"
  }

  description = "Network options"

  validation {
    condition     = contains([false, true], var.network.new)
    error_message = "The network.new value should be false or true."
  }

  validation {
    condition     = can(regex("^[0-9A-Za-z_-]{1,64}$", var.network.name))
    error_message = "The network.name value should be alphanumeric characters and 1-64 characters long."
  }

  validation {
    condition     = can(cidrhost(var.network.address, 0)) && can(cidrnetmask(var.network.address))
    error_message = "The network.address value should be an IP address in CIDR notation."
  }
}

variable "subnet" {
  type = object({
    new     = bool
    name    = string
    address = string
  })

  default = {
    new     = true
    name    = "existing-subnet"
    address = "10.0.0.0/24"
  }

  description = "Subnet options"

  validation {
    condition     = contains([false, true], var.subnet.new)
    error_message = "The subnet.new value should be false or true."
  }

  validation {
    condition     = can(regex("^[0-9A-Za-z_-]{1,64}$", var.subnet.name))
    error_message = "The subnet.name value should be alphanumeric characters and 1-64 characters long."
  }

  validation {
    condition     = can(cidrhost(var.subnet.address, 0)) && can(cidrnetmask(var.subnet.address))
    error_message = "The subnet.address value should be an IP address in CIDR notation."
  }
}

variable "ssh" {
  type = object({
    enable = bool
    source = string
  })

  default = {
    enable = true
    source = "0.0.0.0/0"
  }

  description = "SSH options"

  validation {
    condition     = contains([false, true], var.ssh.enable)
    error_message = "The ssh.enable value should be false or true."
  }

  validation {
    condition     = can(cidrhost(var.ssh.source, 0)) && can(cidrnetmask(var.ssh.source))
    error_message = "The ssh.source value should be an IP address in CIDR notation."
  }
}

variable "http" {
  type = object({
    enable = bool
    source = string
  })

  default = {
    enable = true
    source = "0.0.0.0/0"
  }

  description = "HTTP options"

  validation {
    condition     = contains([false, true], var.http.enable)
    error_message = "The http.enable value should be false or true."
  }

  validation {
    condition     = can(cidrhost(var.http.source, 0)) && can(cidrnetmask(var.http.source))
    error_message = "The http.source value should be an IP address in CIDR notation."
  }
}

variable "mgs" {
  type = object({
    node_type           = string
    node_count          = number
    public_ip           = bool
    accelerated_network = bool
  })

  default = {
    node_type           = "Standard_F4s"
    node_count          = 1
    public_ip           = true
    accelerated_network = true
  }

  description = "Management server options"

  validation {
    condition     = length(var.mgs.node_type) > 0
    error_message = "The mgs.node_type value must not be empty."
  }

  validation {
    condition     = var.mgs.node_count == 1
    error_message = "The mgs.node_count value should be 1."
  }

  validation {
    condition     = contains([false, true], var.mgs.public_ip)
    error_message = "The mgs.public_ip value should be false or true."
  }

  validation {
    condition     = contains([false, true], var.mgs.accelerated_network)
    error_message = "The mgs.accelerated_network value should be false or true."
  }
}

variable "mgt" {
  type = object({
    disk_type  = string
    disk_cache = string
    disk_size  = number
    disk_count = number
  })

  default = {
    disk_type  = "StandardSSD_LRS"
    disk_cache = "None"
    disk_size  = 128
    disk_count = 1
  }

  description = "Management target options"

  validation {
    condition     = contains(["Standard_LRS", "Premium_LRS", "StandardSSD_LRS"], var.mgt.disk_type)
    error_message = "The mgt.disk_type value should be Standard_LRS, Premium_LRS or StandardSSD_LRS."
  }

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.mgt.disk_cache)
    error_message = "The mgt.disk_cache value should be None, ReadOnly or ReadWrite."
  }

  validation {
    condition     = var.mgt.disk_size > 7 && var.mgt.disk_size < 32768
    error_message = "The mgt.disk_size value should be between 8 and 32767."
  }

  validation {
    condition     = abs(var.mgt.disk_size) == var.mgt.disk_size
    error_message = "The mgt.disk_size value should be a positive."
  }

  validation {
    condition     = floor(var.mgt.disk_size) == ceil(var.mgt.disk_size)
    error_message = "The mgt.disk_size must be an integer."
  }

  validation {
    condition     = var.mgt.disk_count == 1
    error_message = "The mgt.disk_count value should be 1."
  }

  validation {
    condition     = abs(var.mgt.disk_count) == var.mgt.disk_count
    error_message = "The mgt.disk_count value should be a positive."
  }

  validation {
    condition     = floor(var.mgt.disk_count) == ceil(var.mgt.disk_count)
    error_message = "The mgt.disk_count must be an integer."
  }
}

variable "mnt" {
  type = object({
    disk_type  = string
    disk_cache = string
    disk_size  = number
    disk_count = number
  })

  default = {
    disk_type  = "StandardSSD_LRS"
    disk_cache = "None"
    disk_size  = 64
    disk_count = 1
  }

  description = "Monitoring target options"

  validation {
    condition     = contains(["Standard_LRS", "Premium_LRS", "StandardSSD_LRS"], var.mnt.disk_type)
    error_message = "The mnt.disk_type value should be Standard_LRS, Premium_LRS or StandardSSD_LRS."
  }

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.mnt.disk_cache)
    error_message = "The mnt.disk_cache value should be None, ReadOnly or ReadWrite."
  }

  validation {
    condition     = var.mnt.disk_size > 7 && var.mnt.disk_size < 32768
    error_message = "The mnt.disk_size value should be between 8 and 32767."
  }

  validation {
    condition     = abs(var.mnt.disk_size) == var.mnt.disk_size
    error_message = "The mnt.disk_size value should be a positive."
  }

  validation {
    condition     = floor(var.mnt.disk_size) == ceil(var.mnt.disk_size)
    error_message = "The mnt.disk_size must be an integer."
  }

  validation {
    condition     = var.mnt.disk_count == 1
    error_message = "The mnt.disk_count value should be 1."
  }

  validation {
    condition     = abs(var.mnt.disk_count) == var.mnt.disk_count
    error_message = "The mnt.disk_count value should be a positive."
  }

  validation {
    condition     = floor(var.mnt.disk_count) == ceil(var.mnt.disk_count)
    error_message = "The mnt.disk_count must be an integer."
  }
}

variable "mds" {
  type = object({
    node_type           = string
    node_count          = number
    public_ip           = bool
    accelerated_network = bool
  })

  default = {
    node_type           = "Standard_E8s_v3"
    node_count          = 1
    public_ip           = false
    accelerated_network = true
  }

  description = "Metadata server options"

  validation {
    condition     = length(var.mds.node_type) > 0
    error_message = "The mds.node_type value must not be empty."
  }

  validation {
    condition     = var.mds.node_count == 1
    error_message = "The mds.node_count value should be 1."
  }

  validation {
    condition     = contains([false, true], var.mds.public_ip)
    error_message = "The mds.public_ip value should be false or true."
  }

  validation {
    condition     = contains([false, true], var.mds.accelerated_network)
    error_message = "The mds.accelerated_network value should be false or true."
  }
}

variable "mdt" {
  type = object({
    disk_type  = string
    disk_cache = string
    disk_size  = number
    disk_count = number
    disk_raid  = bool
  })

  default = {
    disk_type  = "Premium_LRS"
    disk_cache = "None"
    disk_size  = 512
    disk_count = 1
    disk_raid  = false
  }

  description = "Metadata target options"

  validation {
    condition     = contains(["Standard_LRS", "Premium_LRS", "StandardSSD_LRS"], var.mdt.disk_type)
    error_message = "The mdt.disk_type value should be Standard_LRS, Premium_LRS or StandardSSD_LRS."
  }

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.mdt.disk_cache)
    error_message = "The mdt.disk_cache value should be None, ReadOnly or ReadWrite."
  }

  validation {
    condition     = var.mdt.disk_size > 7 && var.mdt.disk_size < 32768
    error_message = "The mdt.disk_size value should be between 8 and 32767."
  }

  validation {
    condition     = abs(var.mdt.disk_size) == var.mdt.disk_size
    error_message = "The mdt.disk_size value should be a positive."
  }

  validation {
    condition     = floor(var.mdt.disk_size) == ceil(var.mdt.disk_size)
    error_message = "The mdt.disk_size must be an integer."
  }

  validation {
    condition     = var.mdt.disk_count > 0 && var.mdt.disk_count <= 32
    error_message = "The mdt.disk_count value should be between 1 and 32."
  }

  validation {
    condition     = abs(var.mdt.disk_count) == var.mdt.disk_count
    error_message = "The mdt.disk_count value should be a positive."
  }

  validation {
    condition     = floor(var.mdt.disk_count) == ceil(var.mdt.disk_count)
    error_message = "The mdt.disk_count must be an integer."
  }

  validation {
    condition     = contains([false, true], var.mdt.disk_raid)
    error_message = "The mdt.disk_raid value should be false or true."
  }
}

variable "oss" {
  type = object({
    node_type           = string
    node_count          = number
    public_ip           = bool
    accelerated_network = bool
  })

  default = {
    node_type           = "Standard_D16s_v3"
    node_count          = 4
    public_ip           = false
    accelerated_network = true
  }

  description = "Storage server options"

  validation {
    condition     = length(var.oss.node_type) > 0
    error_message = "The oss.node_type value must not be empty."
  }

  validation {
    condition     = var.oss.node_count > 0
    error_message = "The oss.node_count must be greater than 0."
  }

  validation {
    condition     = abs(var.oss.node_count) == var.oss.node_count
    error_message = "The oss.node_count value should be a positive."
  }

  validation {
    condition     = floor(var.oss.node_count) == ceil(var.oss.node_count)
    error_message = "The oss.node_count must be an integer."
  }

  validation {
    condition     = contains([false, true], var.oss.public_ip)
    error_message = "The oss.public_ip value should be false or true."
  }

  validation {
    condition     = contains([false, true], var.oss.accelerated_network)
    error_message = "The oss.accelerated_network value should be false or true."
  }
}

variable "ost" {
  type = object({
    disk_type  = string
    disk_cache = string
    disk_size  = number
    disk_count = number
    disk_raid  = bool
  })

  default = {
    disk_type  = "Standard_LRS"
    disk_cache = "None"
    disk_size  = 512
    disk_count = 6
    disk_raid  = false
  }

  description = "Storage target options"

  validation {
    condition     = contains(["Standard_LRS", "Premium_LRS", "StandardSSD_LRS"], var.ost.disk_type)
    error_message = "The ost.disk_type value should be Standard_LRS, Premium_LRS or StandardSSD_LRS."
  }

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.ost.disk_cache)
    error_message = "The ost.disk_cache value should be None, ReadOnly or ReadWrite."
  }

  validation {
    condition     = var.ost.disk_size > 7 && var.ost.disk_size < 32768
    error_message = "The ost.disk_size value should be between 8 and 32767."
  }

  validation {
    condition     = abs(var.ost.disk_size) == var.ost.disk_size
    error_message = "The ost.disk_size value should be a positive."
  }

  validation {
    condition     = floor(var.ost.disk_size) == ceil(var.ost.disk_size)
    error_message = "The ost.disk_size must be an integer."
  }

  validation {
    condition     = var.ost.disk_count > 0 && var.ost.disk_count <= 32
    error_message = "The ost.disk_count value should be between 1 and 32."
  }

  validation {
    condition     = abs(var.ost.disk_count) == var.ost.disk_count
    error_message = "The ost.disk_count value should be a positive."
  }

  validation {
    condition     = floor(var.ost.disk_count) == ceil(var.ost.disk_count)
    error_message = "The ost.disk_count must be an integer."
  }

  validation {
    condition     = contains([false, true], var.ost.disk_raid)
    error_message = "The ost.disk_raid value should be false or true."
  }
}

variable "cls" {
  type = object({
    node_type           = string
    node_count          = number
    public_ip           = bool
    accelerated_network = bool
  })

  default = {
    node_type           = "Standard_D16s_v3"
    node_count          = 4
    public_ip           = false
    accelerated_network = true
  }

  description = "Compute client options"

  validation {
    condition     = length(var.cls.node_type) > 0
    error_message = "The cls.node_type value must not be empty."
  }

  validation {
    condition     = abs(var.cls.node_count) == var.cls.node_count
    error_message = "The cls.node_count value should be a positive."
  }

  validation {
    condition     = floor(var.cls.node_count) == ceil(var.cls.node_count)
    error_message = "The cls.node_count must be an integer."
  }

  validation {
    condition     = contains([false, true], var.cls.public_ip)
    error_message = "The cls.public_ip value should be false or true."
  }

  validation {
    condition     = contains([false, true], var.cls.accelerated_network)
    error_message = "The cls.accelerated_network value should be false or true."
  }
}

variable "clt" {
  type = object({
    disk_type  = string
    disk_cache = string
    disk_size  = number
    disk_count = number
  })

  default = {
    disk_type  = "Standard_LRS"
    disk_cache = "None"
    disk_size  = 32
    disk_count = 0
  }

  description = "Compute target options"

  validation {
    condition     = contains(["Standard_LRS", "Premium_LRS", "StandardSSD_LRS"], var.clt.disk_type)
    error_message = "The clt.disk_type value should be Standard_LRS, Premium_LRS or StandardSSD_LRS."
  }

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.clt.disk_cache)
    error_message = "The clt.disk_cache value should be None, ReadOnly or ReadWrite."
  }

  validation {
    condition     = var.clt.disk_size > 7 && var.clt.disk_size < 32768
    error_message = "The clt.disk_size value should be between 8 and 32767."
  }

  validation {
    condition     = abs(var.clt.disk_size) == var.clt.disk_size
    error_message = "The clt.disk_size value should be a positive."
  }

  validation {
    condition     = floor(var.clt.disk_size) == ceil(var.clt.disk_size)
    error_message = "The clt.disk_size must be an integer."
  }

  validation {
    condition     = var.clt.disk_count >= 0 && var.clt.disk_count <= 32
    error_message = "The clt.disk_count value should be between 0 and 32."
  }

  validation {
    condition     = abs(var.clt.disk_count) == var.clt.disk_count
    error_message = "The clt.disk_count value should be a positive."
  }

  validation {
    condition     = floor(var.clt.disk_count) == ceil(var.clt.disk_count)
    error_message = "The clt.disk_count must be an integer."
  }
}
