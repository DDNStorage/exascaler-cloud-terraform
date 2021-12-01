# EXAScaler Cloud filesystem name
# only alphanumeric characters are allowed,
# and the value must be 1-8 characters long
fsname = "exacloud"

# Project ID to manage resources
# https://cloud.google.com/resource-manager/docs/creating-managing-projects
project = "project-id"

# Zone name to manage resources
# https://cloud.google.com/compute/docs/regions-zones
zone = "us-central1-f"

# Service account name used by deploy application
# https://cloud.google.com/iam/docs/service-accounts
# new: create a new custom service account or use an existing one: true or false
# email: existing service account email address, will be using if new is false
# set email = null to use the default compute service account
service_account = {
  new   = false
  email = null
}

# Waiter to check progress and result for deployment.
# To use Google Deployment Manager:
# waiter = "deploymentmanager"
# To use generic Google Cloud SDK command line:
# waiter = "sdk"
# If you don’t want to wait until the deployment is complete:
# waiter = null
# https://cloud.google.com/deployment-manager/runtime-configurator/creating-a-waiter
waiter = "deploymentmanager"

# Security options
# admin: optional user name for remote SSH access
# Set admin = null to disable creation admin user
# public_key: path to the SSH public key on the local host
# Set public_key = null to disable creation admin user
# block_project_keys: true or false
# Block project-wide public SSH keys if you want to restrict
# deployment to only user with deployment-level public SSH key.
# https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys
# enable_local: true or false, enable or disable firewall rules for local access
# enable_ssh: true or false, enable or disable remote SSH access
# ssh_source_ranges: source IP ranges for remote SSH access in CIDR notation
# enable_http: true or false, enable or disable remote HTTP access
# http_source_ranges: source IP ranges for remote HTTP access in CIDR notation
security = {
  admin              = "stack"
  public_key         = "~/.ssh/id_rsa.pub"
  block_project_keys = true
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

# Network properties
# https://cloud.google.com/vpc/docs/vpc
# routing: network-wide routing mode: REGIONAL or GLOBAL
# tier: networking tier for VM interfaces: STANDARD or PREMIUM
# id: existing network id, will be using if new is false
# auto: create subnets in each region automatically: false or true
# mtu: maximum transmission unit in bytes: 1460 - 1500
# new: create a new network or use an existing one: true or false
# nat: allow instances without external IP to communicate with the outside world: true or false
network = {
  routing = "REGIONAL"
  tier    = "STANDARD"
  id      = "projects/project-name/global/networks/network-name"
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
# id: existing subnetwork id, will be using if new is false
# new: create a new subnetwork or use an existing one: true or false
subnetwork = {
  address = "10.0.0.0/16"
  private = true
  id      = "projects/project-name/regions/region-name/subnetworks/subnetwork-name"
  new     = true
}

# Boot disk properties
# disk_type: pd-standard, pd-ssd or pd-balanced
boot = {
  disk_type = "pd-standard"
}

# Source image properties
# project: project name
# name: image name
image = {
  project = "ddn-public"
  name    = "exascaler-cloud-v523-centos7"
}

# Management server properties
# node_type: type of management server
# https://cloud.google.com/compute/docs/machine-types
# node_cpu: CPU family
# https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform
# nic_type: type of network connectivity, GVNIC or VIRTIO_NET
# https://cloud.google.com/compute/docs/networking/using-gvnic
# public_ip: assign an external IP address, true or false
# node_count: number of management servers
mgs = {
  node_type  = "n2-standard-2"
  node_cpu   = "Intel Cascade Lake"
  nic_type   = "GVNIC"
  public_ip  = true
  node_count = 1
}

# Management target properties
# https://cloud.google.com/compute/docs/disks
# disk_bus: type of management target interface, SCSI or NVME (NVME is for scratch disks only)
# disk_type: type of management target, pd-standard, pd-ssd, pd-balanced or scratch
# disk_size: size of management target in GB (scratch disk size must be exactly 375)
# disk_count: number of management targets
# disk_raid: create striped management target, true or false
mgt = {
  disk_bus   = "SCSI"
  disk_type  = "pd-standard"
  disk_size  = 128
  disk_count = 1
  disk_raid  = false
}

# Monitoring target properties
# https://cloud.google.com/compute/docs/disks
# disk_bus: type of monitoring target interface, SCSI or NVME (NVME is for scratch disks only)
# disk_type: type of monitoring target, pd-standard, pd-ssd, pd-balanced or scratch
# disk_size: size of monitoring target in GB (scratch disk size must be exactly 375)
# disk_count: number of monitoring targets
# disk_raid: create striped monitoring target, true or false
mnt = {
  disk_bus   = "SCSI"
  disk_type  = "pd-standard"
  disk_size  = 128
  disk_count = 1
  disk_raid  = false
}

# Metadata server properties
# node_type: type of metadata server
# https://cloud.google.com/compute/docs/machine-types
# node_cpu: CPU family
# https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform
# nic_type: type of network connectivity, GVNIC or VIRTIO_NET
# https://cloud.google.com/compute/docs/networking/using-gvnic
# public_ip: assign an external IP address, true or false
# node_count: number of metadata servers
mds = {
  node_type  = "n2-standard-2"
  node_cpu   = "Intel Cascade Lake"
  nic_type   = "GVNIC"
  public_ip  = false
  node_count = 1
}

# Metadata target properties
# https://cloud.google.com/compute/docs/disks
# disk_bus: type of metadata target interface, SCSI or NVME (NVME is for scratch disks only)
# disk_type: type of metadata target, pd-standard, pd-ssd, pd-balanced or scratch
# disk_size: size of metadata target in GB (scratch disk size must be exactly 375)
# disk_count: number of metadata targets
# disk_raid: create striped metadata target, true or false
mdt = {
  disk_bus   = "SCSI"
  disk_type  = "pd-ssd"
  disk_size  = 256
  disk_count = 1
  disk_raid  = false
}

# Object Storage server properties
# node_type: type of storage server
# https://cloud.google.com/compute/docs/machine-types
# node_cpu: CPU family
# https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform
# nic_type: type of network connectivity, GVNIC or VIRTIO_NET
# https://cloud.google.com/compute/docs/networking/using-gvnic
# public_ip: assign an external IP address, true or false
# node_count: number of storage servers
oss = {
  node_type  = "n2-standard-2"
  node_cpu   = "Intel Cascade Lake"
  nic_type   = "GVNIC"
  public_ip  = false
  node_count = 1
}

# Object Storage target properties
# https://cloud.google.com/compute/docs/disks
# disk_bus: type of storage target interface, SCSI or NVME (NVME is for scratch disks only)
# disk_type: type of storage target, pd-standard, pd-ssd, pd-balanced or scratch
# disk_size: size of storage target in GB (scratch disk size must be exactly 375)
# disk_count: number of storage targets
# disk_raid: create striped storage target, true or false
ost = {
  disk_bus   = "SCSI"
  disk_type  = "pd-standard"
  disk_size  = 512
  disk_count = 1
  disk_raid  = false
}

# Compute client properties
# node_type: type of compute client
# https://cloud.google.com/compute/docs/machine-types
# node_cpu: CPU family
# https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform
# nic_type: type of network connectivity, GVNIC or VIRTIO_NET
# https://cloud.google.com/compute/docs/networking/using-gvnic
# public_ip: assign an external IP address, true or false
# node_count: number of compute clients
cls = {
  node_type  = "n2-standard-2"
  node_cpu   = "Intel Cascade Lake"
  nic_type   = "GVNIC"
  public_ip  = false
  node_count = 1
}

# Compute client target properties
# https://cloud.google.com/compute/docs/disks
# disk_bus: type of compute target interface, SCSI or NVME (NVME is for scratch disks only)
# disk_type: type of compute target, pd-standard, pd-ssd, pd-balanced or scratch
# disk_size: size of compute target in GB (scratch disk size must be exactly 375)
# disk_count: number of compute targets
clt = {
  disk_bus   = "SCSI"
  disk_type  = "pd-standard"
  disk_size  = 256
  disk_count = 0
}
