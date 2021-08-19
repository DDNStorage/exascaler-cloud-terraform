# Configuration profile name
# small, medium or custom
profile = "custom"

# EXAScaler filesystem name
# only alphanumeric characters are allowed,
# and the value must be 1-8 characters long
fsname = "exacloud"

# Subscription ID
# https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade
subscription = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

# The Azure region to manage resources
# https://azure.microsoft.com/global-infrastructure/geographies
# This option only has effect when used together with the resource_group.new = true
location = "East US"

# Azure offers a range of options for managing availability and resiliency.
# https://docs.microsoft.com/azure/virtual-machines/availability
# Availability type:
# none - no infrastructure redundancy required,
# set - to create an availability set and automatically distribute resources across multiple fault domains
# zone - to physically separate resources within an Azure region
# Availability zone: unique physical locations within a region
# https://docs.microsoft.com/azure/availability-zones
# 1, 2, 3 to explicitly specify the availability zone
# This option only has effect when used together with the availability.type = "zone"
availability = {
  type = "none"
  zone = 1
}

# Resource group options
# https://docs.microsoft.com/azure/azure-resource-manager/management/manage-resource-groups-portal
# new: create a new resource group, or use an existing one: true or false
# name: existing resource group name, will be using if new is false
resource_group = {
  new  = true
  name = "existing-resource-group"
}

# Proximity placement group options
# https://azure.microsoft.com/blog/introducing-proximity-placement-groups
# new: create a new proximity placement group, or use an existing one: true or false
# name: existing proximity placement group name, will be using if new is false
# new = false only has effect when used together with the resource_group.new = false
# and use case is existing resource group with existing proximity placement group
proximity_placement_group = {
  new  = true
  name = "existing-proximity-placement-group"
}

# Network options
# https://docs.microsoft.com/azure/virtual-network/virtual-networks-overview
# new: create a new virtual network, or use an existing one: true or false
# name: existing virtual network name, will be using if new is false
# new = false only has effect when used together with the resource_group.new = false
# and use case is existing resource group with existing virtual network
# address: valid IP address in CIDR notation for the new virtual network
network = {
  new     = true
  name    = "existing-network"
  address = "10.0.0.0/8"
}

# Subnet options
# https://docs.microsoft.com/azure/virtual-network/virtual-networks-overview
# new: create a new subnet, or use an existing one: true or false
# name: existing subnet name, will be using if new is false
# new = false only has effect when used together with the network.new = false
# and use case is existing virtual network with existing subnet
# address: valid IP address in CIDR notation for the new subnet
subnet = {
  new     = true
  name    = "existing-subnet"
  address = "10.0.0.0/24"
}

# Authentication options for remote SSH access
# username: remote user name
# ssh_public_key: path to SSH public key
admin = {
  username       = "stack"
  ssh_public_key = "~/.ssh/id_rsa.pub"
}

# SSH options
# Enable remote SSH access: true or false
# Source IP range for remote SSH access in CIDR notation
ssh = {
  enable = true
  source = "0.0.0.0/0"
}

# HTTP options
# Enable remote HTTP access: true or false
# Source IP range for remote HTTP access in CIDR notation
http = {
  enable = true
  source = "0.0.0.0/0"
}

# Boot disk options
# https://docs.microsoft.com/azure/virtual-machines/disks-types
# disk_type: Standard_LRS, Premium_LRS or StandardSSD_LRS
# disk_cache: None, ReadOnly or ReadWrite
# Specifies the caching requirements for the boot disk
# auto_delete: true or false
# delete the boot disk automatically when deleting the VM
# disk_size in GB
boot = {
  disk_type   = "StandardSSD_LRS"
  disk_cache  = "ReadWrite"
  auto_delete = true
  disk_size   = 64
}

# Source image options
# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/imaging
# publisher: the publisher of the image used to create the virtual machine
# offer: the offer of the image used to create the virtual machine
# sku: the SKU of the image used to create the virtual machine
# version: the version of the image used to create the virtual machine
# accept: true or false, allows accepting the legal terms for a Marketplace image
image = {
  publisher = "ddn-whamcloud-5345716"
  offer     = "exascaler_cloud"
  sku       = "exascaler_cloud_523_centos"
  version   = "5.2.3"
  accept    = false
}

# Storage account options
# https://docs.microsoft.com/azure/storage/common/storage-account-overview
# kind: BlobStorage, BlockBlobStorage, FileStorage, Storage or StorageV2
# tier: Standard or Premium
# replication: LRS, GRS, RAGRS, ZRS, GZRS or RAGZRS
storage_account = {
  kind        = "StorageV2"
  tier        = "Standard"
  replication = "LRS"
}

# Management server options
# node_type: https://docs.microsoft.com/azure/cloud-services/cloud-services-sizes-specs
# public_ip: true or false
# accelerated_network: true or false
# https://docs.microsoft.com/azure/virtual-network/create-vm-accelerated-networking-powershell
mgs = {
  node_type           = "Standard_F4s"
  node_count          = 1
  public_ip           = true
  accelerated_network = true
}

# Management target options
# https://docs.microsoft.com/azure/virtual-machines/disks-types
# disk_type: Standard_LRS, Premium_LRS or StandardSSD_LRS
# disk_cache: None, ReadOnly or ReadWrite
# Specifies the caching requirements for the management target
# disk_size in GB
mgt = {
  disk_type  = "StandardSSD_LRS"
  disk_cache = "None"
  disk_size  = 128
  disk_count = 1
}

# Monitoring target options
# https://docs.microsoft.com/azure/virtual-machines/disks-types
# disk_type: Standard_LRS, Premium_LRS or StandardSSD_LRS
# disk_cache: None, ReadOnly or ReadWrite
# Specifies the caching requirements for the monitoring target
# disk_size in GB
mnt = {
  disk_type  = "StandardSSD_LRS"
  disk_cache = "None"
  disk_size  = 64
  disk_count = 1
}

# Metadata server options
# node_type: https://docs.microsoft.com/azure/cloud-services/cloud-services-sizes-specs
# node_count: number of instances
# public_ip: true or false
# accelerated_network: true or false
# https://docs.microsoft.com/azure/virtual-network/create-vm-accelerated-networking-powershell
mds = {
  node_type           = "Standard_E8s_v3"
  node_count          = 1
  public_ip           = false
  accelerated_network = true
}

# Metadata target options
# https://docs.microsoft.com/azure/virtual-machines/disks-types
# disk_type: Standard_LRS, Premium_LRS or StandardSSD_LRS
# disk_cache: None, ReadOnly or ReadWrite
# Specifies the caching requirements for the metadata target
# disk_size in GB
# disk_raid: true or false
# enables striped volume
mdt = {
  disk_type  = "Premium_LRS"
  disk_cache = "None"
  disk_size  = 512
  disk_count = 1
  disk_raid  = false
}

# Storage server options
# node_type: https://docs.microsoft.com/azure/cloud-services/cloud-services-sizes-specs
# node_count: number of instances
# public_ip: true or false
# accelerated_network: true or false
# https://docs.microsoft.com/azure/virtual-network/create-vm-accelerated-networking-powershell
oss = {
  node_type           = "Standard_D16s_v3"
  node_count          = 4
  public_ip           = false
  accelerated_network = true
}

# Storage target options
# https://docs.microsoft.com/azure/virtual-machines/disks-types
# disk_type: Standard_LRS, Premium_LRS or StandardSSD_LRS
# disk_cache: None, ReadOnly or ReadWrite
# Specifies the caching requirements for the object storage target
# disk_size in GB
# disk_raid: true or false
# enables striped volume
ost = {
  disk_type  = "Standard_LRS"
  disk_cache = "None"
  disk_size  = 512
  disk_count = 6
  disk_raid  = false
}

# Compute client options
# node_type: https://docs.microsoft.com/azure/cloud-services/cloud-services-sizes-specs
# node_count: number of instances
# public_ip: true or false
# accelerated_network: true or false
# https://docs.microsoft.com/azure/virtual-network/create-vm-accelerated-networking-powershell
cls = {
  node_type           = "Standard_D16s_v3"
  node_count          = 4
  public_ip           = false
  accelerated_network = true
}

# Compute target options
# https://docs.microsoft.com/azure/virtual-machines/disks-types
# disk_type: Standard_LRS, Premium_LRS or StandardSSD_LRS
# disk_cache: None, ReadOnly or ReadWrite
# Specifies the caching requirements for the object storage target
# disk_size in GB
# disk_count: number of targets, 0 to disable
clt = {
  disk_type  = "Standard_LRS"
  disk_cache = "None"
  disk_size  = 32
  disk_count = 0
}
