# EXAScaler Cloud Terraform scripts for Google Cloud Platform

The steps below will show how to create a EXAScaler Cloud environment on Google Cloud Platform using Terraform.

## Prerequisites

* You need a [Google](https://cloud.google.com) account
* Your system needs the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) as well as [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

Before deploy Terraform code for Google Cloud Platform, you will need to create and configure a Service Account and Project to create our Service Account. Important notes about a Service Account:
* A Service Account is a special kind of account used by Terraform to make authorized Google Cloud API calls
* A Service Account is identified by its email address, which is unique to the account
* A Service Accounts don’t have password, and cannot log in via browser
* A Service Accounts is associated with private/public RSA key-pairs that are used for authentication to Google Cloud API

You will use a Service Account and its key to allow Terraform to deploy resources.

## Steps to create a Project and a Service Account

Obtains access credentials for your user account via a web-based authorization flow. When this command completes successfully, it sets the active account in the current configuration to the account specified. [Learn more](https://cloud.google.com/sdk/gcloud/reference/auth/login).
```
$ gcloud auth login
```

Create a Project. [Learn more](https://cloud.google.com/sdk/gcloud/reference/projects/create).
```
gcloud projects create ecd85a78
```

Set the Project as default. [Learn more](https://cloud.google.com/sdk/gcloud/reference/config/set).
```
$ gcloud config set project ecd85a78
```

Get list of Billing Accounts. [Learn more](https://cloud.google.com/sdk/gcloud/reference/alpha/billing/accounts/list).
```
$ gcloud alpha billing accounts list
ACCOUNT_ID            NAME                OPEN  MASTER_ACCOUNT_ID
XXXXXX-XXXXXX-XXXXXX  My Billing Account  True
```

Associate a Billing Account with the Project (using some Billing Account ID from the previous step). [Learn more](https://cloud.google.com/sdk/gcloud/reference/alpha/billing/projects/link).
```
$ gcloud alpha billing projects link ecd85a78 --billing-account XXXXXX-XXXXXX-XXXXXX
```

Enable required Google Cloud API services for the Project. [Learn more](https://cloud.google.com/sdk/gcloud/reference/services/enable).
```
$ gcloud services enable cloudbilling.googleapis.com
$ gcloud services enable apigateway.googleapis.com
$ gcloud services enable servicemanagement.googleapis.com
$ gcloud services enable servicecontrol.googleapis.com
$ gcloud services enable compute.googleapis.com
$ gcloud services enable runtimeconfig.googleapis.com
$ gcloud services enable deploymentmanager.googleapis.com
$ gcloud services enable cloudresourcemanager.googleapis.com
```

Create a Service Account. [Learn more](https://cloud.google.com/sdk/gcloud/reference/iam/service-accounts/create).
```
$ gcloud iam service-accounts create ecd85a78 --display-name "Terraform Account"
```

Get a list of service accounts. [Learn more](https://cloud.google.com/sdk/gcloud/reference/iam/service-accounts/list).
```
$ gcloud iam service-accounts list
DISPLAY NAME                            EMAIL                                               DISABLED
Terraform Account                       ecd85a78@ecd85a78.iam.gserviceaccount.com           False
```

Bind the created Service Account to the Project. [Learn more](https://cloud.google.com/sdk/gcloud/reference/projects/add-iam-policy-binding).
```
$ gcloud projects add-iam-policy-binding ecd85a78 --member serviceAccount:ecd85a78@ecd85a78.iam.gserviceaccount.com --role roles/owner
```

Create a key for the Service Account. [Lear more](https://cloud.google.com/sdk/gcloud/reference/iam/service-accounts/keys/create).
```
$ gcloud iam service-accounts keys create credentials.json --iam-account ecd85a78@ecd85a78.iam.gserviceaccount.com
```

Make sure to store the key file `credentials.json` securely, because it can be used to authenticate as your service account. You can move and rename this file however you would like.

## Steps to configure Terraform

Download Terraform [scripts](https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/1.0.0.zip) and extract tarball:
```
$ curl -sL https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/1.0.0.tar.gz | tar xz
```

Change Terraform variables according you requirements:
```
$ cd exascaler-cloud-terraform-scripts-1.0.0/gcp
$ vi terraform.tfvars
```

### List of available variables

#### Common options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `fsname` | `exacloud` | EXAScaler filesystem name        |
| `zone` | `us-central1-f` | Zone name to manage resources |
| `project` | `ecd85a78` | Project ID - please use ID of created project |
| `credentials` | `~/credentials.json` | Path to the [service account key file](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) in JSON format - please use created key |
| `service_account` | `default` | Service account name used by deploy application |

#### Authentication options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `admin.username` | `stack` | User name for remote SSH access |
| `admin.ssh_public_key` | `~/.ssh/id_rsa.pub` | Path to the local SSH public key. This file will be added to admin home directory as `.ssh/authorized_keys` |

#### Security options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `security.enable_ssh` | `true` | `true` or `false`: enable/disable remote SSH access |
| `security.ssh_source_range` | `0.0.0.0/0` | Source IP for remote SSH access |
| `security.enable_http` | `true` | `true` or `false`: enable/disable remote HTTP console |
| `security.http_source_range` | `0.0.0.0/0` | Source IP for remote HTTP access |

#### Network options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `network.routing` | `REGIONAL` | Network-wide routing mode: `REGIONAL` or `GLOBAL`. [Learn more](https://cloud.google.com/vpc/docs/vpc) |
| `network.tier` | `STANDARD` | Networking tier for network interfaces: `STANDARD` or `PREMIUM`. [Learn more](https://cloud.google.com/vpc/docs/vpc) |
| `network.name` | `default` | Existing network name, will be using only if `new` option is `false` |
| `network.auto` | `false` | Create subnets in each region automatically: `true` or `false` |
| `network.mtu` | `1500` | Maximum transmission unit in bytes: 1460 - 1500 |
| `network.new` | `true` | Create a new network, or use an existing one: `true` or `false` |
| `network.nat` | `true` | Allow instances without external IP to communicate with the outside world: `true` or `false` |
| `subnetwork.address` | `10.0.0.0/16` | IP range of internal addresses for a new subnetwork |
| `subnetwork.private` | `true` | When enabled VMs in this subnetwork without external IP addresses can access Google APIs and services by using Private Google Access: `true` or `false`. [Learn more](https://cloud.google.com/vpc/docs/configure-private-google-access) |
| `subnetwork.name` | `default` | Existing subnetwork name, will be using only if `new` option is `false` |
| `subnetwork.new` | `true` | Create a new subnetwork, or use an existing one: `true` or `false` |

#### Boot disk options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `boot.disk_type` | `pd-standard` | Boot disk type: `pd-standard`, `pd-ssd` or `pd-balanced`. [Learn more](https://cloud.google.com/compute/docs/disks) |
| `boot.auto_delete` | `true` | When `auto-delete` is `true`, the boot disk is deleted when the instance it is attached to is deleted |

#### Boot image options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `image.project` | `ddn-public` | Source project name |
| `image.name` | `exascaler-cloud-v522-centos7` | Source image name |

#### Virtual machines options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `{mgs,mds,oss,cls}.node_type` | `n2-standard-2` | Virtual machine type. [Learn more](https://cloud.google.com/compute/docs/machine-types) |
| `{mgs,mds,oss,cls}.node_cpu` | `Intel Cascade Lake` | CPU platform [Learn more](https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform) |
| `{mgs,mds,oss,cls}.nic_type` |  `GVNIC` | Type of network interfac: `GVNIC` or `VIRTIO_NET`. [Learn more](https://cloud.google.com/compute/docs/networking/using-gvnic)|
| `{mgs,mds,oss,cls}.public_ip` | `true` (`mgs`), `false` (`mds`, `oss`, `cls`) | Assign an external IP address: `true` or `false` |
| `{mgs,mds,oss,cls}.node_count` | `1`   | Number of instances (`1` for `mgs` and `mds` instances) |

#### Target disks options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `{mgt,mnt,mdt,ost,clt}.disk_bus` | `SCSI` | `SCSI` or `NVME` (`NVME` can be used for `scratch` disks only) |
| `{mgt,mnt,mdt,ost,clt}.disk_type` | `pd-standard` | `pd-standard`, `pd-ssd`, `pd-balanced` or `scratch`. [Learn more](https://cloud.google.com/compute/docs/disks) |
| `{mgt,mnt,mdt,ost,clt}.disk_size` | `512` | Disk size in GB (ignored for `scratch` disks: local SSD size is 375GB) |
| `{mgt,mnt,mdt,ost,clt}.disk_count` | `1`   | Number of target disks: `1-128` (`1` for `mgt` and `mnt`). [Learn more](https://cloud.google.com/compute/docs/disks) |

Initialize a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control. It is safe to run this command multiple times:
```
$ terraform init
```

Validate configuration options:
```
$ terraform validate
```

Create an execution plan:
```
$ terraform plan
```

Apply the changes required to reach the desired state of the configuration:
```
$ terraform apply
...
  Enter a value: yes
...
 
Apply complete! Resources: 22 added, 0 changed, 0 destroyed.

Outputs:

mount_command = "mount -t lustre 10.0.0.3@tcp:/exacloud /mnt/exacloud"

private_addresses = {
  "exascaler-cloud-7e04-cls0" = "10.0.0.5"
  "exascaler-cloud-7e04-mds0" = "10.0.0.4"
  "exascaler-cloud-7e04-mgs0" = "10.0.0.3"
  "exascaler-cloud-7e04-oss0" = "10.0.0.2"
}

ssh_console = {
  "exascaler-cloud-7e04-mgs0" = "ssh -A stack@35.209.72.61"
}

web_console = "http://35.209.72.61"
```

Now you can access the EXAScaler Cloud environment:
```
$ eval $(ssh-agent)
Agent pid 18111
 
$ ssh-add
Identity added: /home/user/.ssh/id_rsa
 
$ ssh -A stack@35.209.72.61
 
[stack@exascaler-cloud-5fb1-mgs0 ~]$ df -h -t lustre
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdb        499G  2.1M  474G   1% /mnt/targets/MGS
 
[stack@exascaler-cloud-5fb1-mgs0 ~]$ ssh 10.0.0.2

[stack@exascaler-cloud-5fb1-oss0 ~]$ df -h -t lustre
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdb        504G  1.3M  479G   1% /mnt/targets/exacloud-OST0000
```

Destroy the EXAScaler Cloud environment:
```
$ terraform destroy
...
 
  Enter a value: yes
 
...
 
Destroy complete! Resources: 22 destroyed.
```
