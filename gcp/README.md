# Terraform scripts for EXAScaler Cloud on Google Cloud Platform

The steps below will show how to create a EXAScaler Cloud environment on [Google Cloud Platform](https://cloud.google.com) using [Terraform](https://www.terraform.io).

## Prerequisites

* You need a [Google](https://cloud.google.com) account
* Your system needs the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) as well as [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Authentication

Before deploy Terraform code for Google Cloud Platform, you need to authenticate using Google Cloud SDK.

If you are running Terraform on your workstation, you can authenticate using [User Application Default Credentials](https://cloud.google.com/sdk/gcloud/reference/auth/application-default):
```shell
gcloud auth application-default login
```
Output:
```shell
Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?response_type=code

Credentials saved to file: [/Users/user/.config/gcloud/application_default_credentials.json]
```

And Terraform will be able to automatically use the saved User Application Default Credentials to call Google Cloud APIs.

If you are running Terraform on Google Cloud, you can configure that instance or cluster to use a [Google Service Account](https://cloud.google.com/compute/docs/authentication). This will allow Terraform to authenticate to Google Cloud without having to store a separate credential file. [Learn more](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication).

And if you are running Terraform outside of Google Cloud, you can generate an external credential configuration file or a service account key file and set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the path of the JSON file. Terraform will use that file for authentication. In general Terraform supports the full range of authentication options [documented for Google Cloud](https://cloud.google.com/docs/authentication).

## IAM permissions required to deploy EXAScaler Cloud

The [Basic Editor](https://cloud.google.com/iam/docs/understanding-roles) role is required to deploy EXAScaler Cloud environment on Google Cloud Platform.  If you want to use the minimum permissions, create a custom role and assign only the [required permissions](PERMISSIONS.txt).

## Enable Google Cloud API Services

Any actions that Terraform performs require that the API be enabled to do so. Terraform requires the following Google Cloud API Services:
```shell
gcloud services enable cloudbilling.googleapis.com
gcloud services enable apigateway.googleapis.com
gcloud services enable servicemanagement.googleapis.com
gcloud services enable servicecontrol.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable runtimeconfig.googleapis.com
gcloud services enable deploymentmanager.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
```
For a list of services available, visit the [API library page](https://console.cloud.google.com/apis/library) or run gcloud services list --available. [Learn more](https://cloud.google.com/sdk/gcloud/reference/services/enable).

## Configure Terraform

Download Terraform [scripts](https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/2.0.4.zip) and extract tarball:
```shell
curl -sL https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/2.0.4.tar.gz | tar xz
```

Change Terraform variables according you requirements:
```shell
cd exascaler-cloud-terraform-scripts-2.0.4/gcp
vi terraform.tfvars
```

### List of available variables

#### Common options
| Variable  | Default Value   | Description |
| --------- | --------------- | ----------- |
| `fsname`  | `exacloud`      | EXAScaler Cloud filesystem name.        |
| `zone`    | `us-central1-f` | Zone name to manage resources. [Learn more](https://cloud.google.com/compute/docs/regions-zones). |
| `project` | `ecd85a78`      | Project ID to manage resources. [Learn more](https://cloud.google.com/resource-manager/docs/creating-managing-projects). |

### Service account
A service account is a special account that can be used by services and applications running on Google Compute Engine instances to interact with other Google Cloud Platform APIs. [Learn more](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances). EXAScaler Cloud deployments use service account credentials to authorize themselves to a set of APIs and perform actions within the permissions granted to the service account and virtual machine instances. All projects are created with the Compute Engine default service account and this account is assigned the editor role. Google recommends that each instance that needs to call a Google API should run as a service account with the minimum required permissions. Three options are available for EXAScaler Cloud deployment:

* Use the Compute Engine default service account
* Use an existing custom service account (consider the [list of required permissions](main.tf#L81-L92))
* Create a new custom service account and assign it the minimum required privileges 

| Variable               | Default Value | Description |
| ---------------------- | ------------- | ----------- |
| `service_account.new`  | `false`       | Create a new custom service account, or use an existing one: `true` or `false`. |
| `service_account.name` | `default`     | Existing service account name, will be using if `service_account.new` is `false`. |

#### Waiter to check progress and result for deployment
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `waiter` | `deploymentmanager` | Waiter to check progress and result for deployment. To use Google Deployment Manager set `waiter = "deploymentmanager"`. To use generic Google Cloud SDK command line set `waiter = "sdk"`. If you don’t want to wait until the deployment is complete, set `waiter = null`. [Learn more](https://cloud.google.com/deployment-manager/runtime-configurator/creating-a-waiter). |

#### Authentication options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `admin.username` | `stack` | User name for remote SSH access. |
| `admin.ssh_public_key` | `~/.ssh/id_rsa.pub` | Path to the local SSH public key. This file will be added to admin home directory as `.ssh/authorized_keys`. |

#### Security options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `security.enable_local` | `true` | `true` or `false`: enable or disable firewall rules to allow local traffic (TCP/988, TCP/80). |
| `security.enable_ssh` | `true` | `true` or `false`: enable/disable remote SSH access. |
| `security.ssh_source_range` | `0.0.0.0/0` | Source IP for remote SSH access. |
| `security.enable_http` | `true` | `true` or `false`: enable/disable remote HTTP console. |
| `security.http_source_range` | `0.0.0.0/0` | Source IP for remote HTTP access. |

#### Network options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `network.routing` | `REGIONAL` | Network-wide routing mode: `REGIONAL` or `GLOBAL`. [Learn more](https://cloud.google.com/vpc/docs/vpc). |
| `network.tier` | `STANDARD` | Networking tier for network interfaces: `STANDARD` or `PREMIUM`. [Learn more](https://cloud.google.com/vpc/docs/vpc). |
| `network.name` | `default` | Existing network name, will be using only if `new` option is `false`. |
| `network.auto` | `false` | Create subnets in each region automatically: `true` or `false`. |
| `network.mtu` | `1500` | Maximum transmission unit in bytes: 1460 - 1500. |
| `network.new` | `true` | Create a new network, or use an existing one: `true` or `false`. |
| `network.nat` | `true` | Allow instances without external IP to communicate with the outside world: `true` or `false`. |
| `subnetwork.address` | `10.0.0.0/16` | IP address range in CIDR notation of internal addresses for a new or existing subnetwork. |
| `subnetwork.private` | `true` | When enabled VMs in this subnetwork without external IP addresses can access Google APIs and services by using Private Google Access: `true` or `false`. [Learn more](https://cloud.google.com/vpc/docs/configure-private-google-access). |
| `subnetwork.name` | `default` | Existing subnetwork name, will be using only if `new` option is `false`. |
| `subnetwork.new` | `true` | Create a new subnetwork, or use an existing one: `true` or `false`. |

#### Boot disk options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `boot.disk_type` | `pd-standard` | Boot disk type: `pd-standard`, `pd-ssd` or `pd-balanced`. [Learn more](https://cloud.google.com/compute/docs/disks). |
| `boot.auto_delete` | `true` | When `auto-delete` is `true`, the boot disk is deleted when the instance it is attached to is deleted. |

#### Boot image options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `image.project` | `ddn-public` | Source project name |
| `image.name` | `exascaler-cloud-v522-centos7` | Source image name |

#### Virtual machines options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `{mgs,mds,oss,cls}.node_type` | `n2-standard-2` | Virtual machine type. [Learn more](https://cloud.google.com/compute/docs/machine-types). |
| `{mgs,mds,oss,cls}.node_cpu` | `Intel Cascade Lake` | CPU platform [Learn more](https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform). |
| `{mgs,mds,oss,cls}.nic_type` |  `GVNIC` | Type of network interfac: `GVNIC` or `VIRTIO_NET`. [Learn more](https://cloud.google.com/compute/docs/networking/using-gvnic). |
| `{mgs,mds,oss,cls}.public_ip` | `true` (`mgs`), `false` (`mds`, `oss`, `cls`) | Assign an external IP address: `true` or `false` |
| `{mgs,mds,oss,cls}.node_count` | `1`   | Number of instances (`1` for `mgs` and `mds` instances) |

#### Target disks options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `{mgt,mnt,mdt,ost,clt}.disk_bus` | `SCSI` | `SCSI` or `NVME` (`NVME` can be used for `scratch` disks only) |
| `{mgt,mnt,mdt,ost,clt}.disk_type` | `pd-standard` | `pd-standard`, `pd-ssd`, `pd-balanced` or `scratch`. [Learn more](https://cloud.google.com/compute/docs/disks). |
| `{mgt,mnt,mdt,ost,clt}.disk_size` | `512` | Disk size in GB (ignored for `scratch` disks: local SSD size is 375GB) |
| `{mgt,mnt,mdt,ost,clt}.disk_count` | `1`   | Number of target disks: `1-128` (`1` for `mgt` and `mnt`). [Learn more](https://cloud.google.com/compute/docs/disks). |

Initialize a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control. It is safe to run this command multiple times:
```shell
terraform init
```

Validate configuration options:
```shell
terraform validate
```

Create an execution plan:
```shell
terraform plan
```

Apply the changes required to reach the desired state of the configuration:
```shell
terraform apply
```

Output:
```shell
  Enter a value: yes
 
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
