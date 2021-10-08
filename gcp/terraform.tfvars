# EXAScaler filesystem name
# only alphanumeric characters are allowed,
# and the value must be 1-8 characters long
fsname = "exacloud"

# Zone name to manage resources
# https://cloud.google.com/compute/docs/regions-zones
zone = "us-central1-f"

# Project ID
# https://cloud.google.com/resource-manager/docs/creating-managing-projects
project = "ecd85a78"

# Service account name used by deploy application
# https://cloud.google.com/iam/docs/service-accounts
# new: create a new custom service account, or use an existing one: true or false
# name: existing service account name, will be using if new is false
service_account = {
  new  = false
  name = "default"
}

# User for remote SSH access
# username: remote user name
# ssh_public_key: path local SSH public key
# https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys
admin = {
  username       = "stack"
  ssh_public_key = "~/.ssh/id_rsa.pub"
}

# Enable/disable remote SSH access: true or false
# Source IP for remote SSH access: valid CIDR range of the form x.x.x.x/x
# Enable/disable remote HTTP console: true or false
# Source IP for remote HTTP access valid CIDR range of the form x.x.x.x/x
security = {
  enable_ssh        = true
  ssh_source_range  = "0.0.0.0/0"
  enable_http       = true
  http_source_range = "0.0.0.0/0"
}

# Network properties
# https://cloud.google.com/vpc/docs/vpc
# routing: network-wide routing mode: REGIONAL or GLOBAL
# tier: networking tier for VM interfaces: STANDARD or PREMIUM
# name: existing network name, will be using if new is false
# auto: create subnets in each region automatically: false or true
# mtu: maximum transmission unit in bytes: 1460 - 1500
# new: create a new network, or use an existing one: true or false
# nat: allow instances without external IP to communicate with the outside world: true or false
network = {
  routing = "REGIONAL"
  tier    = "STANDARD"
  name    = "default"
  auto    = false
  mtu     = 1500
  new     = true
  nat     = true
}

# Subnetwork properties
# https://cloud.google.com/vpc/docs/vpc
# address: IP range of internal addresses for a new subnetwork
# private: when enabled VMs in this subnetwork without external
# IP addresses can access Google APIs and services by using
# Private Google Access: true or false
# https://cloud.google.com/vpc/docs/private-access-options
# name: existing subnetwork name, will be using if new is false
# new: create a new subnetwork, or use an existing one: true or false
subnetwork = {
  address = "10.0.0.0/16"
  private = true
  name    = "default"
  new     = true
}

# Boot disk properties
# disk_type: pd-standard, pd-ssd or pd-balanced
# auto_delete: true or false
# whether the disk will be auto-deleted when the instance is deleted
boot = {
  disk_type   = "pd-standard"
  auto_delete = true
}

# Source image properties
# project: project name
# name: image name
image = {
  project = "ddn-public"
  name    = "exascaler-cloud-v522-centos7"
}

# Management server properties
# https://cloud.google.com/compute/docs/machine-types
# https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform
# https://cloud.google.com/compute/docs/networking/using-gvnic
# nic_type: GVNIC or VIRTIO_NET
# public_ip: true or false
# node_count: number of instances
mgs = {
  node_type  = "n2-standard-2"
  node_cpu   = "Intel Cascade Lake"
  nic_type   = "GVNIC"
  public_ip  = true
  node_count = 1
}

# Management target properties
# https://cloud.google.com/compute/docs/disks
# disk_bus: SCSI or NVME (NVME is for scratch disks only)
# disk_type: pd-standard, pd-ssd, pd-balanced or scratch
# disk_size: target size in in GB
# scratch disk size must be exactly 375
# disk_count: number of targets
mgt = {
  disk_bus   = "SCSI"
  disk_type  = "pd-standard"
  disk_size  = 128
  disk_count = 1
}

# Monitoring target properties
# https://cloud.google.com/compute/docs/disks
# disk_bus: SCSI or NVME (NVME is for scratch disks only)
# disk_type: pd-standard, pd-ssd, pd-balanced or scratch
# disk_size: target size in in GB
# scratch disk size must be exactly 375
# disk_count: number of targets
mnt = {
  disk_bus   = "SCSI"
  disk_type  = "pd-standard"
  disk_size  = 128
  disk_count = 1
}

# Metadata server properties
# https://cloud.google.com/compute/docs/machine-types
# https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform
# https://cloud.google.com/compute/docs/networking/using-gvnic
# nic_type: GVNIC or VIRTIO_NET
# public_ip: true or false
# node_count: number of instances
mds = {
  node_type  = "n2-standard-2"
  node_cpu   = "Intel Cascade Lake"
  nic_type   = "GVNIC"
  public_ip  = false
  node_count = 1
}

# Metadata target properties
# https://cloud.google.com/compute/docs/disks
# disk_bus: SCSI or NVME (NVME is for scratch disks only)
# disk_type: pd-standard, pd-ssd, pd-balanced or scratch
# disk_size: target size in in GB
# scratch disk size must be exactly 375
# disk_count: number of targets
mdt = {
  disk_bus   = "SCSI"
  disk_type  = "pd-ssd"
  disk_size  = 256
  disk_count = 1
}

# Object Storage server properties
# https://cloud.google.com/compute/docs/machine-types
# https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform
# https://cloud.google.com/compute/docs/networking/using-gvnic
# nic_type: GVNIC or VIRTIO_NET
# public_ip: true or false
oss = {
  node_type  = "n2-standard-2"
  node_cpu   = "Intel Cascade Lake"
  nic_type   = "GVNIC"
  public_ip  = false
  node_count = 1
}

# Object Storage target properties
# https://cloud.google.com/compute/docs/disks
# disk_bus: SCSI or NVME (NVME is for scratch disks only)
# disk_type: pd-standard, pd-ssd, pd-balanced or scratch
# disk_size: target size in in GB
# scratch disk size must be exactly 375
# disk_count: number of targets
ost = {
  disk_bus   = "SCSI"
  disk_type  = "pd-standard"
  disk_size  = 512
  disk_count = 1
}

# Compute client properties
# https://cloud.google.com/compute/docs/machine-types
# https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform
# https://cloud.google.com/compute/docs/networking/using-gvnic
# nic_type: GVNIC or VIRTIO_NET
# public_ip: true or false
# node_count: number of instances
cls = {
  node_type  = "n2-standard-2"
  node_cpu   = "Intel Cascade Lake"
  nic_type   = "GVNIC"
  public_ip  = false
  node_count = 1
}

# Compute client target properties
# https://cloud.google.com/compute/docs/disks
# disk_bus: SCSI or NVME (NVME is for scratch disks only)
# disk_type: pd-standard, pd-ssd, pd-balanced or scratch
# disk_size: target size in in GB
# scratch disk size must be exactly 375
# disk_count: number of targets, 0 to disable
clt = {
  disk_bus   = "SCSI"
  disk_type  = "pd-standard"
  disk_size  = 256
  disk_count = 0
}
