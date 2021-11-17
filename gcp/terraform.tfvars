# EXAScaler Cloud filesystem name
# only alphanumeric characters are allowed,
# and the value must be 1-8 characters long
fsname = "exacloud"

# Project ID
# https://cloud.google.com/resource-manager/docs/creating-managing-projects
project = "project-id"

# Zone name to manage resources
# https://cloud.google.com/compute/docs/regions-zones
zone = "us-central1-f"

# Service account name used by deploy application
# https://cloud.google.com/iam/docs/service-accounts
# new: create a new custom service account, or use an existing one: true or false
# name: existing service account name, will be using if new is false
service_account = {
  new  = false
  name = "default"
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
  block_project_keys = false
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
# new: create a new network, or use an existing one: true or false
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
# new: create a new subnetwork, or use an existing one: true or false
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
