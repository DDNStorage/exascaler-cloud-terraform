# Terraform scripts for EXAScaler Cloud on Google Cloud Platform

* [Supported products](#supported-products)
* [Prerequisites](#prerequisites)
* [Authentication](#authentication)
* [IAM permissions required to deploy EXAScaler Cloud](#iam-permissions-required-to-deploy-exascaler-cloud)
* [Enable Google Cloud API Services](#enable-google-cloud-api-services)
* [Configure Terraform](#configure-terraform)
  + [List of available variables](#list-of-available-variables)
    - [Common options](#common-options)
    - [Service account](#service-account)
    - [Waiter to check progress and result for deployment](#waiter-to-check-progress-and-result-for-deployment)
    - [Security options](#security-options)
    - [Network options](#network-options)
    - [Subnetwork options](#subnetwork-options)
    - [Boot disk options](#boot-disk-options)
    - [Boot image options](#boot-image-options)
    - [Management server options](#management-server-options)
    - [Management target options](#management-target-options)
    - [Monitoring target options](#monitoring-target-options)
    - [Metadata server options](#metadata-server-options)
    - [Metadata target options](#metadata-target-options)
    - [Object Storage server options](#object-storage-server-options)
    - [Object Storage target options](#object-storage-target-options)
    - [Compute client options](#compute-client-options)
    - [Compute client target options](#compute-client-target-options)
* [Deploy an EXAScaler Cloud environment](#deploy-an-exascaler-cloud-environment)
* [Access the EXAScaler Cloud environment](#access-the-exascaler-cloud-environment)
* [Add storage capacity in an existing EXAScaler Cloud environment](#add-storage-capacity-in-an-existing-exascaler-cloud-environment)
* [Upgrade an existing EXAScaler Cloud environment](#upgrade-an-existing-exascaler-cloud-environment)
* [Run benchmarks](#run-benchmarks)
* [Install new EXAScaler Cloud clients](#install-new-exascaler-cloud-clients)
* [Client-side encryption](#client-side-encryption)
* [Collect inventory and support bundle](#collect-inventory-and-support-bundle)
* [Destroy the EXAScaler Cloud environment](#destroy-the-exascaler-cloud-environment)

The steps below will show how to create a EXAScaler Cloud environment on [Google Cloud Platform](https://cloud.google.com) using [Terraform](https://www.terraform.io).

## Supported products

| Product | Version | Base OS | Image family |
| ------- | ------- | ------- | ------------ |
| EXAScaler Cloud | 5.2.6 | Red Hat Enterprise Linux 7.9 | `exascaler-cloud-5-2-redhat` |
| EXAScaler Cloud | 5.2.6 | CentOS Linux 7.9 | `exascaler-cloud-5-2-centos` |
| EXAScaler Cloud | 6.0.1 | Red Hat Enterprise Linux 7.9 | `exascaler-cloud-6-0-redhat` |
| EXAScaler Cloud | 6.0.1 | CentOS Linux 7.9 | `exascaler-cloud-6-0-centos` |
| EXAScaler Cloud | 6.1.0 | Red Hat Enterprise Linux 7.9 | `exascaler-cloud-6-1-redhat` |
| EXAScaler Cloud | 6.1.0 | CentOS Linux 7.9 | `exascaler-cloud-6-1-centos` |

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

Download Terraform [scripts](https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/2.1.6.zip) and extract tarball:
```shell
curl -sL https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/2.1.6.tar.gz | tar xz
```

Change Terraform variables according you requirements:
```shell
cd exascaler-cloud-terraform-scripts-2.1.6/gcp
vi terraform.tfvars
```

### List of available variables

#### Common options
| Variable  | Type     | Default         | Description |
| --------: | -------: | --------------: | ----------- |
| `prefix`  | `string` | `null`          | EXAScaler Cloud custom deployment prefix. Set this option to add a custom prefix to all created objects. |
| `labels`  | `map`    | `{}`            | EXAScaler Cloud custom deployment labels. Set this option to add a custom labels to all created objects. |
| `fsname`  | `string` | `exacloud`      | EXAScaler Cloud filesystem name. |
| `project` | `string` | `project-id`    | Project ID to manage resources. [Learn more](https://cloud.google.com/resource-manager/docs/creating-managing-projects). |
| `zone`    | `string` | `us-central1-f` | Zone name to manage resources. [Learn more](https://cloud.google.com/compute/docs/regions-zones). |

#### Service account
A service account is a special account that can be used by services and applications running on Google Compute Engine instances to interact with other Google Cloud Platform APIs. [Learn more](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances). EXAScaler Cloud deployments use service account credentials to authorize themselves to a set of APIs and perform actions within the permissions granted to the service account and virtual machine instances. All projects are created with the Compute Engine default service account and this account is assigned the editor role. Google recommends that each instance that needs to call a Google API should run as a service account with the minimum required permissions. Three options are available for EXAScaler Cloud deployment:

* Use the Compute Engine default service account
* Use an existing custom service account (consider the [list of required permissions](main.tf#L82-L92))
* Create a new custom service account and assign it the minimum required privileges 

| Variable                | Typei    | Default       | Description |
| ----------------------: | -------: | ------------: | ----------- |
| `service_account.new`   | `string` | `false`       | Create a new custom service account and assign it the minimum required privileges, or use an existing service account: `true` or `false`. |
| `service_account.email` | `string` | `null`        | Existing service account email address, will be using if `service_account.new` is `false`. Set `email = null` to use the default compute service account. [Learn more](https://cloud.google.com/iam/docs/service-accounts). |

#### Waiter to check progress and result for deployment
| Variable | Type     | Default | Description |
| -------: | -------: | ------: | ----------- |
| `waiter` | `string` | `deploymentmanager` | Waiter to check progress and result for deployment. To use Google Deployment Manager set `waiter = "deploymentmanager"`. To use generic Google Cloud SDK command line set `waiter = "sdk"`. If you don’t want to wait until the deployment is complete, set `waiter = null`. [Learn more](https://cloud.google.com/deployment-manager/runtime-configurator/creating-a-waiter). |

#### Security options
| Variable                      | Type     | Default  | Description |
| ----------------------------: | -------: | -------: | ----------- |
| `security.admin`              | `string` | `stack`  | Optional user name for remote SSH access. Set `admin = null` to disable creation admin user. [Learn more](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys). |
| `security.public_key`         | `string` | `~/.ssh/id_rsa.pub` | Path to the SSH public key on the local host. Set `public_key = null` to disable creation admin user. [Learn more](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys). |
| `security.block_project_keys` | `bool`   | `true`              | Block project-wide public SSH keys if you want to restrict deployment to only user with deployment-level public SSH key. [Learn more](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys). |
| `security.enable_os_login`    | `bool`   | `false`             | `true` or `false`: enable or disable OS Login. Please note, enabling this option disables other security options: `security.admin`, `security.public_key` and `security.block_project_keys`.  [Learn more](https://cloud.google.com/compute/docs/instances/managing-instance-access#enable_oslogin). |
| `security.enable_local`       | `bool`   | `true`              | `true` or `false`: enable or disable firewall rules to allow local traffic (TCP/988 and TCP/80). |
| `security.enable_ssh`         | `bool`   | `true`              | `true` or `false`: enable/disable remote SSH access. [Learn more](https://cloud.google.com/vpc/docs/firewalls). |
| `security.enable_http`        | `bool`   | `true`              | `true` or `false`: enable/disable remote HTTP console. [Learn more](https://cloud.google.com/vpc/docs/firewalls). |
| `security.ssh_source_ranges`  | `list(string)` | `[0.0.0.0/0]` | Source IP ranges for remote SSH access in CIDR notation. [Learn more](https://cloud.google.com/vpc/docs/firewalls). |
| `security.http_source_ranges` | `list(string)` | `[0.0.0.0/0]` | Source IP ranges for remote HTTP access in CIDR notation. [Learn more](https://cloud.google.com/vpc/docs/firewalls). |

#### Network options
| Variable             | Type     | Default    | Description |
| -------------------: | -------: | ---------: | ----------- |
| `network.routing`    | `string` | `REGIONAL` | Network-wide routing mode: `REGIONAL` or `GLOBAL`. [Learn more](https://cloud.google.com/vpc/docs/vpc). |
| `network.tier`       | `string` | `STANDARD` | Networking tier for network interfaces: `STANDARD` or `PREMIUM`. [Learn more](https://cloud.google.com/vpc/docs/vpc). |
| `network.id`         | `string` | `projects/project-id/global/networks/network-name` | Existing network `id`, will be using only if `network.new` option is `false`. [Learn more](https://cloud.google.com/vpc/docs/vpc). |
| `network.auto`       | `bool`   | `false`    | Create subnets in each region automatically: `true` or `false`. [Learn more](https://cloud.google.com/vpc/docs/vpc).|
| `network.mtu`        | `integer` | `1500`    | Maximum transmission unit in bytes: 1460 - 1500. [Learn more](https://cloud.google.com/vpc/docs/vpc). |
| `network.new`        | `bool` | `true`       | Create a new network, or use an existing network: `true` or `false`. |
| `network.nat`        | `bool` | `true`       | Allow instances without external IP to communicate with the outside world: `true` or `false`. [Learn more](https://cloud.google.com/nat/docs/overview). |

#### Subnetwork options
| Variable             | Type     | Default       | Description |
| -------------------: | -------: | ------------: | ----------- |
| `subnetwork.address` | `string` | `10.0.0.0/16` | IP address range in CIDR notation of internal addresses for a new or existing subnetwork. |
| `subnetwork.private` | `bool`   | `true` | When enabled VMs in this subnetwork without external IP addresses can access Google APIs and services by using Private Google Access: `true` or `false`. [Learn more](https://cloud.google.com/vpc/docs/configure-private-google-access). |
| `subnetwork.id`      | `string` | `projects/project-id/regions/region-name/subnetworks/subnetwork-name` | Existing subnetwork `id`, will be using only if `subnetwork.new` option is `false`. |
| `subnetwork.new`     | `bool` | `true` | Create a new subnetwork, or use an existing subnetwork: `true` or `false`. |

Note: to provide access to the Google Cloud API, one of the following conditions must be met:
* the subnetwork must be configured with enabled [Private Google Access](https://cloud.google.com/vpc/docs/configure-private-google-access)
* all VM instances must have external IP addresses
* NAT option must be enabled

#### Boot disk options
| Variable         | Type     | Default       | Description |
| ---------------: | -------: | ------------: | ----------- |
| `boot.disk_type` | `string` | `pd-standard` | Boot disk type: <ul><li>`pd-standard`</li><li>`pd-balanced`</li><li>`pd-ssd`</li><li>`pd-extreme`</li></ul> [Learn more](https://cloud.google.com/compute/docs/disks). |
| `boot.script_url` | `string` | `null` | User defined startup script that is stored in Cloud Storage. [Learn more](https://cloud.google.com/compute/docs/instances/startup-scripts/linux). |

#### Boot image options
| Variable        | Type     | Default      | Description |
| --------------: | -------: | -----------: | ----------- |
| `image.project` | `string` | `ddn-public` | Source project name. [Learn more](https://cloud.google.com/compute/docs/images). |
| `image.family`    | `string` | `exascaler-cloud-6-1-centos7` | Source image family to create the virtual machine. EXAScaler Cloud 5.2 images: <ul><li>`exascaler-cloud-5-2-centos`</li><li>`exascaler-cloud-5-2-redhat`</li></ul>EXAScaler Cloud 6.0 images: <ul><li>`exascaler-cloud-6-0-centos`</li><li>`exascaler-cloud-6-0-redhat`</li></ul>EXAScaler Cloud 6.1 images: <ul><li>`exascaler-cloud-6-1-centos`</li><li>`exascaler-cloud-6-1-redhat`</li></ul> [Learn more](https://cloud.google.com/compute/docs/images). |

#### Management server options
| Variable         | Type      | Default              | Description |
| ---------------: | --------: | -------------------: | ----------- |
| `mgs.node_type`  | `string`  | `n2-standard-2`      | Type of management server. [Learn more](https://cloud.google.com/compute/docs/machine-types). |
| `mgs.node_cpu`   | `string`  | `Intel Cascade Lake` | CPU platform. [Learn more](https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform). |
| `mgs.nic_type`   | `string`  | `GVNIC`              | Type of network interface: `GVNIC` or `VIRTIO_NET`. [Learn more](https://cloud.google.com/compute/docs/networking/using-gvnic). |
| `mgs.public_ip`  | `bool`    | `true`               | Assign an external IP address: `true` or `false`. |
| `mgs.node_count` | `integer` | `1`                  | Number of management servers: `1`. |

#### Management target options
| Variable         |  Type    | <img width=100/> Default | Description |
| ---------------: | -------: | ------------: | ----------- |
| `mgt.disk_bus`   | `string` | `SCSI`        | Type of management target interface: `SCSI` or `NVME` (`NVME` can be used for `scratch` disks only). [Learn more](https://cloud.google.com/compute/docs/disks/local-ssd). |
| `mgt.disk_type`  | `string` | `pd-standard` | Type of management target: <ul><li>`pd-standard`</li><li>`pd-balanced`</li><li>`pd-ssd`</li><li>`pd-extreme`</li><li>`scratch`</li></ul> [Learn more](https://cloud.google.com/compute/docs/disks). |
| `mgt.disk_size`  | `integer` | `128`        | Size of management target in GB (ignored for `scratch` disks: local SSD size is 375GB). [Learn more](https://cloud.google.com/compute/docs/disks/local-ssd). |
| `mgt.disk_count` | `integer` | `1`          | Number of management targets: `1-128`. [Learn more](https://cloud.google.com/compute/docs/disks). |
| `mgt.disk_raid`  | `bool`    | `false`      | Create striped management target: `true` or `false`. |

#### Monitoring target options
| Variable         | Type      | <img width=100/> Default       | Description |
| ---------------: | --------: | ------------: | ----------- |
| `mnt.disk_bus`   | `string`  | `SCSI`        | Type of monitoring target interface: `SCSI` or `NVME` (`NVME` can be used for `scratch` disks only). [Learn more](https://cloud.google.com/compute/docs/disks/local-ssd). |
| `mnt.disk_type`  | `string`  | `pd-standard` | Type of monitoring target: <ul><li>`pd-standard`</li><li>`pd-balanced`</li><li>`pd-ssd`</li><li>`pd-extreme`</li><li>`scratch`</li></ul> [Learn more](https://cloud.google.com/compute/docs/disks). |
| `mnt.disk_size`  | `integer` | `128`         | Size of monitoring target in GB (ignored for `scratch` disks: local SSD size is 375GB). [Learn more](https://cloud.google.com/compute/docs/disks/local-ssd). |
| `mnt.disk_count` | `integer` | `1`           | Number of monitoring targets: `1-128`. [Learn more](https://cloud.google.com/compute/docs/disks). |
| `mnt.disk_raid`  | `bool`    | `false`       | Create striped management target: `true` or `false`. |

#### Metadata server options
| Variable         | Type      | Default              | Description |
| ---------------: | --------: | -------------------: | ----------- |
| `mds.node_type`  | `string`  | `n2-standard-2`      | Type of metadata server. [Learn more](https://cloud.google.com/compute/docs/machine-types). |
| `mds.node_cpu`   | `string`  | `Intel Cascade Lake` | CPU platform. [Learn more](https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform). |
| `mds.nic_type`   | `string`  | `GVNIC`              | Type of network interface: `GVNIC` or `VIRTIO_NET`. [Learn more](https://cloud.google.com/compute/docs/networking/using-gvnic). |
| `mds.public_ip`  | `bool`    | `true`               | Assign an external IP address: `true` or `false`. |
| `mds.node_count` | `integer` | `1`                  | Number of metadata servers: `1-32`. |

#### Metadata target options
| Variable         | Type      | <img width=100/> Default  | Description |
| ---------------: | --------: | -------: | ----------- |
| `mdt.disk_bus`   | `string`  | `SCSI`   | Type of metadata target interface: `SCSI` or `NVME` (`NVME` can be used for `scratch` disks only). [Learn more](https://cloud.google.com/compute/docs/disks/local-ssd). |
| `mdt.disk_type`  | `string`  | `pd-ssd` | Type of metadata target: <ul><li>`pd-standard`</li><li>`pd-balanced`</li><li>`pd-ssd`</li><li>`pd-extreme`</li><li>`scratch`</li></ul> [Learn more](https://cloud.google.com/compute/docs/disks). |
| `mdt.disk_size`  | `integer` | `256`    | Size of metadata target in GB (ignored for `scratch` disks: local SSD size is 375GB). [Learn more](https://cloud.google.com/compute/docs/disks/local-ssd). |
| `mdt.disk_count` | `integer` | `1`      | Number of metadata targets: `1-128`. [Learn more](https://cloud.google.com/compute/docs/disks). |
| `mdt.disk_raid`  | `bool`    | `false`  | Create striped metadata target: `true` or `false`. |

#### Object Storage server options
| Variable         | Type      | Default              | Description |
| ---------------: | --------: | -------------------: | ----------- |
| `oss.node_type`  | `string`  | `n2-standard-2`      | Type of object storage server. [Learn more](https://cloud.google.com/compute/docs/machine-types). |
| `oss.node_cpu`   | `string`  | `Intel Cascade Lake` | CPU platform. [Learn more](https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform). |
| `oss.nic_type`   | `string`  | `GVNIC`              | Type of network interface: `GVNIC` or `VIRTIO_NET`. [Learn more](https://cloud.google.com/compute/docs/networking/using-gvnic). |
| `oss.public_ip`  | `bool`    | `true`               | Assign an external IP address: `true` or `false`. |
| `oss.node_count` | `integer` | `1`                  | Number of object storage servers: `1-2000`. |

#### Object Storage target options
| Variable         | Type      | <img width=100/> Default       | Description |
| ---------------: | --------: | ------------: | ----------- |
| `ost.disk_bus`   | `string`  | `SCSI`        | Type of object storage target interface: `SCSI` or `NVME` (`NVME` can be used for `scratch` disks only). [Learn more](https://cloud.google.com/compute/docs/disks/local-ssd). |
| `ost.disk_type`  | `string`  | `pd-standard` | Type of object storage target: <ul><li>`pd-standard`</li><li>`pd-balanced`</li><li>`pd-ssd`</li><li>`pd-extreme`</li><li>`scratch`</li></ul> [Learn more](https://cloud.google.com/compute/docs/disks). |
| `ost.disk_size`  | `integer` | `512`         | Size of object storage target in GB (ignored for `scratch` disks: local SSD size is 375GB). [Learn more](https://cloud.google.com/compute/docs/disks/local-ssd). |
| `ost.disk_count` | `integer` | `1`           | Number of object storage targets: `1-128`. [Learn more](https://cloud.google.com/compute/docs/disks). |
| `ost.disk_raid`  | `bool`    | `false`       | Create striped object storage target: `true` or `false`. |

#### Compute client options
| Variable         | Type      | Default              | Description |
| ---------------: | --------: | -------------------: | ----------- |
| `cls.node_type`  | `string`  | `n2-standard-2`      | Type of compute client. [Learn more](https://cloud.google.com/compute/docs/machine-types). |
| `cls.node_cpu`   | `string`  | `Intel Cascade Lake` | CPU platform. [Learn more](https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform). |
| `cls.nic_type`   | `string`  | `GVNIC`              | Type of network interface: `GVNIC` or `VIRTIO_NET`. [Learn more](https://cloud.google.com/compute/docs/networking/using-gvnic). |
| `cls.public_ip`  | `bool`    | `true`               | Assign an external IP address: `true` or `false`. |
| `cls.node_count` | `integer` | `1`                  | Number of compute clients: `0` or more. |

#### Compute client target options
| Variable         | Type      | <img width=100/> Default       | Description |
| ---------------: | --------: | ------------: | ----------- |
| `clt.disk_bus`   | `string`  | `SCSI`        | Type of compute target interface: `SCSI` or `NVME` (`NVME` can be used for `scratch` disks only). [Learn more](https://cloud.google.com/compute/docs/disks/local-ssd). |
| `clt.disk_type`  | `string`  | `pd-standard` | Type of compute target: <ul><li>`pd-standard`</li><li>`pd-balanced`</li><li>`pd-ssd`</li><li>`pd-extreme`</li><li>`scratch`</li></ul> [Learn more](https://cloud.google.com/compute/docs/disks). |
| `clt.disk_size`  | `integer` | `256`         | Size of compute target in GB (ignored for `scratch` disks: local SSD size is 375GB). [Learn more](https://cloud.google.com/compute/docs/disks/local-ssd). |
| `clt.disk_count` | `integer` | `0`           | Number of compute targets: `0-128`. [Learn more](https://cloud.google.com/compute/docs/disks). |

## Deploy an EXAScaler Cloud environment

Initialize a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control. It is safe to run this command multiple times:
```shell
terraform init
```

Output:
```shell
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/google-beta...
- Finding latest version of hashicorp/null...
- Finding latest version of hashicorp/random...
- Finding latest version of hashicorp/template...
- Installing hashicorp/google-beta v4.1.0...
- Installed hashicorp/google-beta v4.1.0 (signed by HashiCorp)
- Installing hashicorp/null v3.1.0...
- Installed hashicorp/null v3.1.0 (signed by HashiCorp)
- Installing hashicorp/random v3.1.0...
- Installed hashicorp/random v3.1.0 (signed by HashiCorp)
- Installing hashicorp/template v2.2.0...
- Installed hashicorp/template v2.2.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Validate configuration options:
```shell
terraform validate
```

Output:
```shell
$ terraform validate

Success! The configuration is valid.
```

Create an execution plan with a preview of the changes that Terraform will make to the environment:
```shell
terraform plan
```

Apply the changes required to reach the desired state of the configuration:
```shell
terraform apply
```

Output:
```shell
$ terraform apply
 ...
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
 ...
Apply complete! Resources: 112 added, 0 changed, 0 destroyed.

Outputs:

http_console = "http://35.208.94.252"

mount_command = "mount -t lustre 10.0.0.22@tcp:/exacloud /mnt/exacloud"

private_addresses = {
  "exascaler-cloud-2db9-cls0" = "10.0.0.19"
  "exascaler-cloud-2db9-cls1" = "10.0.0.23"
  "exascaler-cloud-2db9-cls2" = "10.0.0.21"
  "exascaler-cloud-2db9-cls3" = "10.0.0.9"
  "exascaler-cloud-2db9-cls4" = "10.0.0.25"
  "exascaler-cloud-2db9-cls5" = "10.0.0.18"
  "exascaler-cloud-2db9-cls6" = "10.0.0.20"
  "exascaler-cloud-2db9-cls7" = "10.0.0.2"
  "exascaler-cloud-2db9-mds0" = "10.0.0.24"
  "exascaler-cloud-2db9-mgs0" = "10.0.0.22"
  "exascaler-cloud-2db9-oss0" = "10.0.0.7"
  "exascaler-cloud-2db9-oss1" = "10.0.0.3"
  "exascaler-cloud-2db9-oss10" = "10.0.0.14"
  "exascaler-cloud-2db9-oss11" = "10.0.0.4"
  "exascaler-cloud-2db9-oss12" = "10.0.0.16"
  "exascaler-cloud-2db9-oss13" = "10.0.0.11"
  "exascaler-cloud-2db9-oss14" = "10.0.0.13"
  "exascaler-cloud-2db9-oss15" = "10.0.0.27"
  "exascaler-cloud-2db9-oss2" = "10.0.0.8"
  "exascaler-cloud-2db9-oss3" = "10.0.0.17"
  "exascaler-cloud-2db9-oss4" = "10.0.0.15"
  "exascaler-cloud-2db9-oss5" = "10.0.0.26"
  "exascaler-cloud-2db9-oss6" = "10.0.0.5"
  "exascaler-cloud-2db9-oss7" = "10.0.0.12"
  "exascaler-cloud-2db9-oss8" = "10.0.0.10"
  "exascaler-cloud-2db9-oss9" = "10.0.0.6"
}

ssh_console = {
  "exascaler-cloud-2db9-mgs0" = "ssh -A stack@35.208.94.252"
}
```

## Access the EXAScaler Cloud environment

Now you can access the EXAScaler Cloud environment:
```shell
eval $(ssh-agent)
ssh-add
```

Output:
```shell
$ eval $(ssh-agent)
Agent pid 18111
 
$ ssh-add
Identity added: /home/user/.ssh/id_rsa

$ ssh -A stack@35.208.94.252

[stack@exascaler-cloud-2db9-mgs0 ~]$ df -h -t lustre
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdb        124G  2.3M  123G   1% /mnt/targets/MGS

[stack@exascaler-cloud-2db9-mgs0 ~]$ loci hosts
10.0.0.19	exascaler-cloud-2db9-cls0
10.0.0.23	exascaler-cloud-2db9-cls1
10.0.0.21	exascaler-cloud-2db9-cls2
10.0.0.9	exascaler-cloud-2db9-cls3
10.0.0.25	exascaler-cloud-2db9-cls4
10.0.0.18	exascaler-cloud-2db9-cls5
10.0.0.20	exascaler-cloud-2db9-cls6
10.0.0.2	exascaler-cloud-2db9-cls7
10.0.0.24	exascaler-cloud-2db9-mds0
10.0.0.22	exascaler-cloud-2db9-mgs0
10.0.0.7	exascaler-cloud-2db9-oss0
10.0.0.3	exascaler-cloud-2db9-oss1
10.0.0.14	exascaler-cloud-2db9-oss10
10.0.0.4	exascaler-cloud-2db9-oss11
10.0.0.16	exascaler-cloud-2db9-oss12
10.0.0.11	exascaler-cloud-2db9-oss13
10.0.0.13	exascaler-cloud-2db9-oss14
10.0.0.27	exascaler-cloud-2db9-oss15
10.0.0.8	exascaler-cloud-2db9-oss2
10.0.0.17	exascaler-cloud-2db9-oss3
10.0.0.15	exascaler-cloud-2db9-oss4
10.0.0.26	exascaler-cloud-2db9-oss5
10.0.0.5	exascaler-cloud-2db9-oss6
10.0.0.12	exascaler-cloud-2db9-oss7
10.0.0.10	exascaler-cloud-2db9-oss8
10.0.0.6	exascaler-cloud-2db9-oss9

[stack@exascaler-cloud-2db9-mgs0 ~]$ ssh exascaler-cloud-2db9-cls0

[stack@exascaler-cloud-2db9-cls0 ~]$ lfs df
UUID                   1K-blocks        Used   Available Use% Mounted on
exacloud-MDT0000_UUID   315302464        6020   309927736   1% /mnt/exacloud[MDT:0] 
exacloud-OST0000_UUID  3712813504        1260  3675214900   1% /mnt/exacloud[OST:0]
exacloud-OST0001_UUID  3712813504        1264  3675214896   1% /mnt/exacloud[OST:1]
exacloud-OST0002_UUID  3712813504        1264  3675214896   1% /mnt/exacloud[OST:2]
exacloud-OST0003_UUID  3712813504        1268  3675214892   1% /mnt/exacloud[OST:3]
exacloud-OST0004_UUID  3712813504        1264  3675214896   1% /mnt/exacloud[OST:4]
exacloud-OST0005_UUID  3712813504        1256  3675214904   1% /mnt/exacloud[OST:5]
exacloud-OST0006_UUID  3712813504        1256  3675214904   1% /mnt/exacloud[OST:6]
exacloud-OST0007_UUID  3712813504        1260  3675214900   1% /mnt/exacloud[OST:7]
exacloud-OST0008_UUID  3712813504        1260  3675214900   1% /mnt/exacloud[OST:8]
exacloud-OST0009_UUID  3712813504        1260  3675214900   1% /mnt/exacloud[OST:9]
exacloud-OST000a_UUID  3712813504        1260  3675214900   1% /mnt/exacloud[OST:10]
exacloud-OST000b_UUID  3712813504        1268  3675214892   1% /mnt/exacloud[OST:11]
exacloud-OST000c_UUID  3712813504        1264  3675214896   1% /mnt/exacloud[OST:12]
exacloud-OST000d_UUID  3712813504        1268  3675214892   1% /mnt/exacloud[OST:13]
exacloud-OST000e_UUID  3712813504        1264  3675214896   1% /mnt/exacloud[OST:14]
exacloud-OST000f_UUID  3712813504        1256  3675214904   1% /mnt/exacloud[OST:15]

filesystem_summary:  59405016064       20192 58803438368   1% /mnt/exacloud
```

## Add storage capacity in an existing EXAScaler Cloud environment

The storage capacity can be added by increasing the number of storage servers. To add storage capacity in an existing EXAScaler Cloud environment, just modify the `terraform.tfvars` file and increase the number of object storage servers (the value of the `oss.node_count` variable) as required:
```shell
$ diff -u terraform.tfvars.orig terraform.tfvars
--- terraform.tfvars.orig	2021-12-01 20:11:30.000000000 +0300
+++ terraform.tfvars	2021-12-01 20:11:43.000000000 +0300
@@ -202,7 +202,7 @@
   node_cpu   = "Intel Cascade Lake"
   nic_type   = "GVNIC"
   public_ip  = false
-  node_count = 16
+  node_count = 24
 }
 
 # Object Storage target properties
```

And then run the `terraform apply` command to increase the storage capacity. The available storage capacity (in GB) can be calculated by multiplying the three configuration parameters:
```shell
capacity = oss.node_count * ost.disk_count * ost.disk_size
```

## Upgrade an existing EXAScaler Cloud environment

A software upgrade for an existing EXAScaler Cloud environment is possible by recreating the running VM instances using a new version of the OS image. And it requires some manual steps.

Create a backup copy for the existing Terraform directory (`*.tf`, `terraform.tfvars` and `terraform.tfstate` files):
```shell
cd /path/to/exascaler-cloud-terraform-scripts-x.y.z/gcp
tar pcfz backup.tgz *.tf terraform.tfvars terraform.tfstate
```

Update Terraform scripts using the latest available EXAScaler Cloud Terraform [scripts](https://github.com/DDNStorage/exascaler-cloud-terraform):
```shell
cd /path/to
curl -sL https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/2.1.6.tar.gz | tar xz
cd exascaler-cloud-terraform-scripts-2.1.6/gcp
```

Copy the `terraform.tfstate` file from the existing Terraform directory:
```shell
cp -iv /path/to/exascaler-cloud-terraform-scripts-x.y.z/gcp/terraform.tfstate .
```

Review and update the `terraform.tfvars` file using configuration options for the existing environment:
```shell
diff -u  /path/to/exascaler-cloud-terraform-scripts-x.y.z/az/terraform.tfvars terraform.tfvars
vi terraform.tfvars
```

Review the execution plan to make sure all changes are expected:
```shell
terraform plan
```

Apply the changes required to upgrade the existing EXAScaler Cloud environment by recreating all instances using the latest version of EXAScaler Cloud image:
```shell
terraform apply
```

## Run benchmarks

Steps to run [IOR](https://ior.readthedocs.io) benchmark on the EXAScaler Cloud deployment:

* Run [ssh-agent](https://linux.die.net/man/1/ssh-agent)
* Add [ssh private key](https://linux.die.net/man/1/ssh-add)
* Open an SSH session to the EXAScaler Cloud management server
* Run [IOR](https://wiki.lustre.org/IOR) benchmark using `esc-ior` tool

```shell
eval $(ssh-agent)
ssh-add
ssh -A stack@35.208.94.252
esc-ior
```

Output:
```shell
$ eval $(ssh-agent)
Agent pid 97037

$ ssh-add
Identity added: /home/user/.ssh/id_rsa

$ ssh -A stack@35.208.94.252

[stack@exascaler-cloud-2db9-mgs0 ~]$ esc-ior
IOR-3.3.0: MPI Coordinated Test of Parallel I/O
Began               : Wed Dec  1 17:29:55 2021
Command line        : /usr/bin/ior -C -F -e -r -w -a POSIX -b 16777216 -t 1048576 -s 539 -o /mnt/exacloud/ceb67656ef7da04e/ceb67656ef7da04e
Machine             : Linux exascaler-cloud-2db9-cls0
TestID              : 0
StartTime           : Wed Dec  1 17:29:55 2021
Path                : /mnt/exacloud/ceb67656ef7da04e
FS                  : 55.3 TiB   Used FS: 0.0%   Inodes: 204.8 Mi   Used Inodes: 0.0%

Options: 
api                 : POSIX
apiVersion          : 
test filename       : /mnt/exacloud/ceb67656ef7da04e/ceb67656ef7da04e
access              : file-per-process
type                : independent
segments            : 539
ordering in a file  : sequential
ordering inter file : constant task offset
task offset         : 1
nodes               : 8
tasks               : 64
clients per node    : 8
repetitions         : 1
xfersize            : 1 MiB
blocksize           : 16 MiB
aggregate filesize  : 539 GiB

Results: 

access    bw(MiB/s)  IOPS       Latency(s)  block(KiB) xfer(KiB)  open(s)    wr/rd(s)   close(s)   total(s)   iter
------    ---------  ----       ----------  ---------- ---------  --------   --------   --------   --------   ----
write     6335       6335       5.44        16384      1024.00    0.016925   87.13      3.56       87.13      0   
read      7438       7438       4.59        16384      1024.00    0.081018   74.20      20.08      74.20      0   
remove    -          -          -           -          -          -          -          -          1.30       0   
Max Write: 6334.77 MiB/sec (6642.49 MB/sec)
Max Read:  7438.33 MiB/sec (7799.66 MB/sec)

Summary of all tests:
Operation   Max(MiB)   Min(MiB)  Mean(MiB)     StdDev   Max(OPs)   Min(OPs)  Mean(OPs)     StdDev    Mean(s) Stonewall(s) Stonewall(MiB) Test# #Tasks tPN reps fPP reord reordoff reordrand seed segcnt   blksiz    xsize aggs(MiB)   API RefNum
write        6334.77    6334.77    6334.77       0.00    6334.77    6334.77    6334.77       0.00   87.12805         NA            NA     0     64   8    1   1     1        1         0    0    539 16777216  1048576  551936.0 POSIX      0
read         7438.33    7438.33    7438.33       0.00    7438.33    7438.33    7438.33       0.00   74.20155         NA            NA     0     64   8    1   1     1        1         0    0    539 16777216  1048576  551936.0 POSIX      0
Finished            : Wed Dec  1 17:32:38 2021
```

Steps to run [mdtest](https://wiki.lustre.org/MDTest) benchmark on the EXAScaler Cloud deployment:

* Run [ssh-agent](https://linux.die.net/man/1/ssh-agent)
* Add [ssh private key](https://linux.die.net/man/1/ssh-add)
* Open an SSH session to the EXAScaler Cloud management server
* Run [mdtest](https://wiki.lustre.org/MDTest) benchmark using `esc-mdtest` tool

```shell
eval $(ssh-agent)
ssh-add
ssh -A stack@35.208.94.252
esc-mdtest
```

Output:
```shell
$ eval $(ssh-agent)
Agent pid 97079

$ ssh-add
Identity added: /home/user/.ssh/id_rsa

$ ssh -A stack@35.208.94.252

[stack@exascaler-cloud-2db9-mgs0 ~]$ esc-mdtest
-- started at 12/01/2021 17:34:01 --

mdtest-3.3.0 was launched with 64 total task(s) on 8 node(s)
Command line used: /usr/bin/mdtest '-n' '2048' '-i' '3' '-d' '/mnt/exacloud/b10eab2f2e7ccbd3'
Path: /mnt/exacloud
FS: 55.3 TiB   Used FS: 0.0%   Inodes: 204.8 Mi   Used Inodes: 0.0%

Nodemap: 1111111100000000000000000000000000000000000000000000000000000000
64 tasks, 131072 files/directories

SUMMARY rate: (of 3 iterations)
   Operation                      Max            Min           Mean        Std Dev
   ---------                      ---            ---           ----        -------
   Directory creation        :      26871.818      16015.007      22434.966       4648.316
   Directory stat            :      36404.916      33826.426      34857.190       1113.203
   Directory removal         :      28108.093      24667.200      26016.682       1498.696
   File creation             :      22421.537      13454.293      19186.060       4063.924
   File stat                 :      47499.280      46180.116      46829.212        536.436
   File read                 :      28638.415      28146.821      28323.202        222.232
   File removal              :      18023.544      17765.493      17866.900        111.632
   Tree creation             :       2113.490       1218.897       1728.448        375.678
   Tree removal              :        276.874        155.710        229.802         53.027
-- finished at 12/01/2021 17:35:52 --
```

Steps to run [IO500](https://io500.org) benchmark on the EXAScaler Cloud deployment:

* Run [ssh-agent](https://linux.die.net/man/1/ssh-agent)
* Add [ssh private key](https://linux.die.net/man/1/ssh-add)
* Open an SSH session to the EXAScaler Cloud management server
* Open an SSH session to the any EXAScaler Cloud compute host
* Run [IO500](https://github.com/IO500/io500) benchmark using `esc-io500` tool

```shell
eval $(ssh-agent)
ssh-add
ssh -A stack@35.208.94.252
loci hosts -c
ssh -A exascaler-cloud-2db9-cls0
esc-io500
```

Output:
```shell
$ eval $(ssh-agent)
Agent pid 97092

$ ssh-add
Identity added: /home/user/.ssh/id_rsa

$ ssh -A stack@35.208.94.252

[stack@exascaler-cloud-2db9-mgs0 ~]$ loci hosts
10.0.0.19	exascaler-cloud-2db9-cls0
10.0.0.23	exascaler-cloud-2db9-cls1
10.0.0.21	exascaler-cloud-2db9-cls2
10.0.0.9	exascaler-cloud-2db9-cls3
10.0.0.25	exascaler-cloud-2db9-cls4
10.0.0.18	exascaler-cloud-2db9-cls5
10.0.0.20	exascaler-cloud-2db9-cls6
10.0.0.2	exascaler-cloud-2db9-cls7
10.0.0.24	exascaler-cloud-2db9-mds0
10.0.0.22	exascaler-cloud-2db9-mgs0
10.0.0.7	exascaler-cloud-2db9-oss0
10.0.0.3	exascaler-cloud-2db9-oss1
10.0.0.14	exascaler-cloud-2db9-oss10
10.0.0.4	exascaler-cloud-2db9-oss11
10.0.0.16	exascaler-cloud-2db9-oss12
10.0.0.11	exascaler-cloud-2db9-oss13
10.0.0.13	exascaler-cloud-2db9-oss14
10.0.0.27	exascaler-cloud-2db9-oss15
10.0.0.8	exascaler-cloud-2db9-oss2
10.0.0.17	exascaler-cloud-2db9-oss3
10.0.0.15	exascaler-cloud-2db9-oss4
10.0.0.26	exascaler-cloud-2db9-oss5
10.0.0.5	exascaler-cloud-2db9-oss6
10.0.0.12	exascaler-cloud-2db9-oss7
10.0.0.10	exascaler-cloud-2db9-oss8
10.0.0.6	exascaler-cloud-2db9-oss9

$ ssh -A exascaler-cloud-2db9-cls0

[stack@exascaler-cloud-2db9-cls0 ~]$ esc-io500
Build IO500 package

Start IO500 benchmark with options:

Data directory:     /mnt/exacloud/e143a2b031294f51/workload
Hosts list:         10.0.0.19,10.0.0.23,10.0.0.21,10.0.0.9,10.0.0.25,10.0.0.18,10.0.0.20,10.0.0.2
Processes per host: 8
Files per process:  129281
Number of tasks:    64
Number of segments: 459375
Block size:         56371445760
Transfer size:      1048576

IO500 version io500-sc20_v3
[RESULT]       ior-easy-write        6.173493 GiB/s : time 329.228 seconds
[RESULT]    mdtest-easy-write       21.002955 kIOPS : time 401.247 seconds
[RESULT]       ior-hard-write        0.328757 GiB/s : time 544.235 seconds
[RESULT]    mdtest-hard-write        9.818279 kIOPS : time 369.694 seconds
[RESULT]                 find      255.641154 kIOPS : time 46.224 seconds
[RESULT]        ior-easy-read        6.647157 GiB/s : time 305.766 seconds
[RESULT]     mdtest-easy-stat       63.395256 kIOPS : time 130.730 seconds
[RESULT]        ior-hard-read        0.902677 GiB/s : time 198.271 seconds
[RESULT]     mdtest-hard-stat       27.472745 kIOPS : time 128.768 seconds
[RESULT]   mdtest-easy-delete       11.505903 kIOPS : time 719.628 seconds
[RESULT]     mdtest-hard-read       10.385374 kIOPS : time 340.405 seconds
[RESULT]   mdtest-hard-delete        7.021386 kIOPS : time 503.496 seconds
[SCORE] Bandwidth 1.868072 GiB/s : IOPS 22.952705 kiops : TOTAL 6.548076

The result files are stored in the directory: ./results/2021.12.01-18.23.49
Warning: please create a 'system-information.txt' description by
copying the information from https://vi4io.org/io500-info-creator/
‘./io500.sh’ -> ‘./results/2021.12.01-18.23.49/io500.sh’
‘config.ini’ -> ‘./results/2021.12.01-18.23.49/config.ini’
Created result tarball ./results/io500-exascaler-cloud-2db9-cls0-2021.12.01-18.23.49.tgz
/mnt/exacloud/e143a2b031294f51/sources/results
2021.12.01-18.23.49  io500-exascaler-cloud-2db9-cls0-2021.12.01-18.23.49.tgz
```

## Install new EXAScaler Cloud clients

New EXAScaler Cloud client instances must be in the same location and connected to the virtual network and subnet. The process of installing and configuring new clients can be performed automatically. All required information is contained in the Terraform output. To configure EXAScaler Cloud filesystem on a new client instance create a configuration file `/etc/esc-client.cfg` using the actual IP address of the management server:
```shell
{
    "Version": "2.0.0",
    "MountConfig": {
        "ClientDevice": "10.0.0.10@tcp:/exacloud",
        "Mountpoint": "/mnt/exacloud",
        "PackageSource": "http://10.0.0.10/client-packages"
    }
}
```

To install and setup EXAScaler Cloud filesystem on a new client run the following commands on the client with root privileges:
```shell
curl -fsSL http://10.0.0.10/client-setup-tool -o /usr/sbin/esc-client
chmod +x /usr/sbin/esc-client
esc-client auto setup --config /etc/esc-client.cfg
```

#### Output for Ubuntu Linux:
```shell
# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 22.04 LTS
Release:	22.04
Codename:	jammy

# esc-client auto setup --config /etc/esc-client.cfg
Discovering platform ... Done.
Configuring firewall rules for Lustre ... Done.
Configuring Lustre client package source ... Done.
Installing Lustre client packages and building DKMS modules ... Done.
Mounting 10.0.0.10@tcp0:/exacloud at /mnt/exacloud ... Done.

# mount -t lustre
10.0.0.10@tcp:/exacloud on /mnt/exacloud type lustre (rw,flock,user_xattr,lazystatfs,encrypt)
```

#### Output for Alma Linux:
```shell
# cat /etc/redhat-release
AlmaLinux release 8.6 (Sky Tiger)

# esc-client auto setup --config /etc/esc-client.cfg
Discovering platform ... Done.
Configuring firewall rules for Lustre ... Done.
Configuring Lustre client package source ... Done.
Installing Lustre client packages ... Done.
Mounting 10.0.0.10@tcp0:/exacloud at /mnt/exacloud ... Done.

# mount -t lustre
10.0.0.10@tcp:/exacloud on /mnt/exacloud type lustre (rw,seclabel,flock,user_xattr,lazystatfs,encrypt)
```

## Client-side encryption

The purpose that client-side encryption wants to serve is to be able to provide a special directory for each user, to safely store sensitive files. The goals are to protect data in transit between clients and servers, and protect data at rest.

This feature is implemented directly at the Lustre client level. Lustre client-side encryption relies on kernel fscrypt. fscrypt is a library which filesystems can hook into to support transparent encryption of files and directories. As a consequence, the key points described below are extracted from [fscrypt](https://github.com/google/fscrypt) documentation.

The client-side encryption feature is available natively on Lustre clients running a Linux distributions, including RHEL/CentOS 8.1 and later, Ubuntu 18.04 and later.

Client-side encryption supports data encryption and file and directory names encryption. Ability to encrypt file and directory names is governed by parameter named `enable_filename_encryption` and set to `0` by default. When this parameter is `0`, new empty directories configured as encrypted use content encryption only, and not name encryption. This mode is inherited for all subdirectories and files. When `enable_filename_encryption` parameter is set to `1`, new empty directories configured as encrypted use full encryption capabilities by encrypting file content and also file and directory names. This mode is inherited for all subdirectories and files. To set the `enable_filename_encryption` parameter globally for all clients, one can do on the management server:
```shell
lctl set_param -P llite.*.enable_filename_encryption=1
```

The fscrypt package is included in the EXAScaler Cloud client toolkit and can be installed using esc-client.

Steps to install Lustre client and fscrypt packages:
```shell
cat > /etc/esc-client.cfg <<EOF
{
    "Version": "2.0.0",
    "MountConfig": {
        "ClientDevice": "10.0.0.10@tcp:/exacloud",
        "Mountpoint": "/mnt/exacloud",
        "PackageSource": "http://10.0.0.10/client-packages"
    }
}
EOF

curl -fsSL http://10.0.0.10/client-setup-tool -o /usr/sbin/esc-client
chmod +x /usr/sbin/esc-client
esc-client auto setup --config /etc/esc-client.cfg
```

Output:
```shell
# esc-client auto setup --config /etc/esc-client.cfg
Discovering platform ... Done.
Configuring firewall rules for Lustre ... Done.
Configuring Lustre client package source ... Done.
Installing Lustre client packages ... Done.
Mounting 10.0.0.10@tcp0:/exacloud at /mnt/exacloud ... Done.

# rpm -q fscrypt lustre-client kmod-lustre-client
fscrypt-0.3.3-1.wc2.x86_64
lustre-client-2.14.0_ddn52-1.el8.x86_64
kmod-lustre-client-2.14.0_ddn52-1.el8.x86_64
```

Steps to configure client-side encryption:
```shell
$ sudo fscrypt setup
Defaulting to policy_version 2 because kernel supports it.
Customizing passphrase hashing difficulty for this system...
Created global config file at "/etc/fscrypt.conf".
Allow users other than root to create fscrypt metadata on the root filesystem? (See
https://github.com/google/fscrypt#setting-up-fscrypt-on-a-filesystem) [y/N]
Metadata directories created at "/.fscrypt", writable by root only.

$ sudo fscrypt setup /mnt/exacloud
Allow users other than root to create fscrypt metadata on this filesystem? (See
https://github.com/google/fscrypt#setting-up-fscrypt-on-a-filesystem) [y/N] y
Metadata directories created at "/mnt/exacloud/.fscrypt", writable by everyone.
```

Steps to encrypt directory:
```shell
$ sudo install -v -d -m 0755 -o stack -g stack /mnt/exacloud/stack
install: creating directory '/mnt/exacloud/stack'

$ fscrypt encrypt /mnt/exacloud/stack
The following protector sources are available:
1 - Your login passphrase (pam_passphrase)
2 - A custom passphrase (custom_passphrase)
3 - A raw 256-bit key (raw_key)
Enter the source number for the new protector [2 - custom_passphrase]:
Enter a name for the new protector: test
Enter custom passphrase for protector "test":
Confirm passphrase:
"/mnt/exacloud/stack" is now encrypted, unlocked, and ready for use.

$ cp -v /etc/passwd /mnt/exacloud/stack/
'/etc/passwd' -> '/mnt/exacloud/stack/passwd'

$ ls -l /mnt/exacloud/stack/
total 1
-rw-r--r--. 1 stack stack 1610 Jul 13 20:34 passwd

$ md5sum /mnt/exacloud/stack/passwd
867541523c51f8cfd4af91988e9f8794  /mnt/exacloud/stack/passwd
```

Lock the directory:
```shell
$ fscrypt lock /mnt/exacloud/stack
"/mnt/exacloud/stack" is now locked.

$ ls -l /mnt/exacloud/stack
total 4
-rw-r--r--. 1 stack stack 4096 Jul 13 20:34 ydpdwRP7MiXzsTkYhg0mW3DNacDlsUJdJa2e9l6AQKL

$ md5sum /mnt/exacloud/stack/ydpdwRP7MiXzsTkYhg0mW3DNacDlsUJdJa2e9l6AQKL
md5sum: /mnt/exacloud/stack/ydpdwRP7MiXzsTkYhg0mW3DNacDlsUJdJa2e9l6AQKL: Required key not available
```

Unlock the directory:
```shell
$ fscrypt unlock /mnt/exacloud/stack
Enter custom passphrase for protector "test":
"/mnt/exacloud/stack" is now unlocked and ready for use.

$ ls -l /mnt/exacloud/stack
total 4
-rw-r--r--. 1 stack stack 1610 Jul 13 20:34 passwd

$ md5sum /mnt/exacloud/stack/passwd
867541523c51f8cfd4af91988e9f8794  /mnt/exacloud/stack/passwd
```

[Learn more about client-side encryption](https://doc.lustre.org/lustre_manual.xhtml#managingSecurity.clientencryption).


## Collect inventory and support bundle

Steps to collect a support bundle on the EXAScaler Cloud deployment:

* Run [ssh-agent](https://linux.die.net/man/1/ssh-agent)
* Add [ssh private key](https://linux.die.net/man/1/ssh-add)
* Open an SSH session to the EXAScaler Cloud management server
* Collect an inventory using `about_this_deployment` tool
* Collect a support bundle using `esc-collector` tool

```shell
eval $(ssh-agent)
ssh-add
ssh -A stack@35.208.94.252
about_this_deployment
esc-collector
```

Output:
```shell
$ eval $(ssh-agent)
Agent pid 97351

$ ssh-add
Identity added: /home/user/.ssh/id_rsa

$ ssh -A stack@35.208.94.252

[stack@exascaler-cloud-2db9-mgs0 ~]$ about_this_deployment
cloud: Google Compute Engine
zone: us-central1-f
project: exascaler-on-gcp
deployment: exascaler-cloud-2db9
filesystem: exacloud
capacityGB: 57344
profile: custom
instances:
- id: 550026747925107041
  instanceName: exascaler-cloud-2db9-oss9
  instanceType: n2-standard-8
  cpuPlatform: Intel Cascade Lake
  role: ost
  interfaces:
  - name: nic0
    type: GVNIC
    network: exascaler-cloud-2db9-network
    subnet: exascaler-cloud-2db9-subnetwork
    privateIpAddress: 10.0.0.6
  disks:
  - blockSize: 4096
    status: READY
    sourceImage: exascaler-cloud-v523-centos7
    mode: READ_WRITE
    bus: SCSI
    boot: true
    autoDelete: true
    lun: 0
    sizeGB: 20
    name: exascaler-cloud-2db9-oss9-boot-disk
    tier: PERSISTENT
    type: pd-standard
  - role: ost
    blockSize: 4096
    status: READY
    mode: READ_WRITE
    bus: SCSI
    boot: false
    autoDelete: false
    lun: 1
    sizeGB: 3584
    name: exascaler-cloud-2db9-oss9-ost0-disk
    tier: PERSISTENT
    type: pd-standard
  status: RUNNING
  tags:
  - exascaler-cloud-2db9
  metadata:
  - key: block-project-ssh-keys
    value: true
 ...

[stack@exascaler-cloud-2db9-mgs0 ~]$ esc-collector
sos-collector (version 1.8)

This utility is used to collect sosreports from multiple nodes simultaneously.
It uses OpenSSH's ControlPersist feature to connect to nodes and run commands
remotely. If your system installation of OpenSSH is older than 5.6, please
upgrade.

An archive of sosreport tarballs collected from the nodes will be generated in
/var/tmp/sos-collector-OfipHI and may be provided to an appropriate support
representative.

The following is a list of nodes to collect from:
	                          
	exascaler-cloud-2db9-cls0 
	exascaler-cloud-2db9-cls1 
	exascaler-cloud-2db9-cls2 
	exascaler-cloud-2db9-cls3 
	exascaler-cloud-2db9-cls4 
	exascaler-cloud-2db9-cls5 
	exascaler-cloud-2db9-cls6 
	exascaler-cloud-2db9-cls7 
	exascaler-cloud-2db9-mds0 
	exascaler-cloud-2db9-mgs0 
	exascaler-cloud-2db9-oss0 
	exascaler-cloud-2db9-oss1 
	exascaler-cloud-2db9-oss10
	exascaler-cloud-2db9-oss11
	exascaler-cloud-2db9-oss12
	exascaler-cloud-2db9-oss13
	exascaler-cloud-2db9-oss14
	exascaler-cloud-2db9-oss15
	exascaler-cloud-2db9-oss2 
	exascaler-cloud-2db9-oss3 
	exascaler-cloud-2db9-oss4 
	exascaler-cloud-2db9-oss5 
	exascaler-cloud-2db9-oss6 
	exascaler-cloud-2db9-oss7 
	exascaler-cloud-2db9-oss8 
	exascaler-cloud-2db9-oss9 


Connecting to nodes...

Beginning collection of sosreports from 26 nodes, collecting a maximum of 2 concurrently

exascaler-cloud-2db9-mgs0   : Generating sosreport...
exascaler-cloud-2db9-oss7   : Generating sosreport...
exascaler-cloud-2db9-oss7   : Retrieving sosreport...
exascaler-cloud-2db9-oss7   : Successfully collected sosreport
exascaler-cloud-2db9-mgs0   : Retrieving sosreport...
exascaler-cloud-2db9-mgs0   : Successfully collected sosreport
exascaler-cloud-2db9-oss6   : Generating sosreport...
exascaler-cloud-2db9-oss5   : Generating sosreport...
exascaler-cloud-2db9-oss5   : Retrieving sosreport...
exascaler-cloud-2db9-oss6   : Retrieving sosreport...
exascaler-cloud-2db9-oss5   : Successfully collected sosreport
exascaler-cloud-2db9-oss6   : Successfully collected sosreport
exascaler-cloud-2db9-oss4   : Generating sosreport...
exascaler-cloud-2db9-oss3   : Generating sosreport...
exascaler-cloud-2db9-oss3   : Retrieving sosreport...
exascaler-cloud-2db9-oss4   : Retrieving sosreport...
exascaler-cloud-2db9-oss3   : Successfully collected sosreport
exascaler-cloud-2db9-oss4   : Successfully collected sosreport
exascaler-cloud-2db9-oss2   : Generating sosreport...
exascaler-cloud-2db9-oss1   : Generating sosreport...
exascaler-cloud-2db9-oss2   : Retrieving sosreport...
exascaler-cloud-2db9-oss1   : Retrieving sosreport...
exascaler-cloud-2db9-oss2   : Successfully collected sosreport
exascaler-cloud-2db9-oss1   : Successfully collected sosreport
exascaler-cloud-2db9-oss0   : Generating sosreport...
exascaler-cloud-2db9-oss8   : Generating sosreport...
exascaler-cloud-2db9-oss8   : Retrieving sosreport...
exascaler-cloud-2db9-oss0   : Retrieving sosreport...
exascaler-cloud-2db9-oss8   : Successfully collected sosreport
exascaler-cloud-2db9-oss0   : Successfully collected sosreport
exascaler-cloud-2db9-oss9   : Generating sosreport...
exascaler-cloud-2db9-oss15  : Generating sosreport...
exascaler-cloud-2db9-oss15  : Retrieving sosreport...
exascaler-cloud-2db9-oss15  : Successfully collected sosreport
exascaler-cloud-2db9-mds0   : Generating sosreport...
exascaler-cloud-2db9-oss9   : Retrieving sosreport...
exascaler-cloud-2db9-oss9   : Successfully collected sosreport
exascaler-cloud-2db9-oss14  : Generating sosreport...
exascaler-cloud-2db9-oss14  : Retrieving sosreport...
exascaler-cloud-2db9-oss14  : Successfully collected sosreport
exascaler-cloud-2db9-oss13  : Generating sosreport...
exascaler-cloud-2db9-mds0   : Retrieving sosreport...
exascaler-cloud-2db9-mds0   : Successfully collected sosreport
exascaler-cloud-2db9-oss12  : Generating sosreport...
exascaler-cloud-2db9-oss13  : Retrieving sosreport...
exascaler-cloud-2db9-oss13  : Successfully collected sosreport
exascaler-cloud-2db9-oss11  : Generating sosreport...
exascaler-cloud-2db9-oss12  : Retrieving sosreport...
exascaler-cloud-2db9-oss12  : Successfully collected sosreport
exascaler-cloud-2db9-cls0   : Generating sosreport...
exascaler-cloud-2db9-oss11  : Retrieving sosreport...
exascaler-cloud-2db9-oss11  : Successfully collected sosreport
exascaler-cloud-2db9-oss10  : Generating sosreport...
exascaler-cloud-2db9-cls0   : Retrieving sosreport...
exascaler-cloud-2db9-cls0   : Successfully collected sosreport
exascaler-cloud-2db9-cls1   : Generating sosreport...
exascaler-cloud-2db9-oss10  : Retrieving sosreport...
exascaler-cloud-2db9-oss10  : Successfully collected sosreport
exascaler-cloud-2db9-cls2   : Generating sosreport...
exascaler-cloud-2db9-cls1   : Retrieving sosreport...
exascaler-cloud-2db9-cls1   : Successfully collected sosreport
exascaler-cloud-2db9-cls3   : Generating sosreport...
exascaler-cloud-2db9-cls2   : Retrieving sosreport...
exascaler-cloud-2db9-cls2   : Successfully collected sosreport
exascaler-cloud-2db9-cls4   : Generating sosreport...
exascaler-cloud-2db9-cls3   : Retrieving sosreport...
exascaler-cloud-2db9-cls3   : Successfully collected sosreport
exascaler-cloud-2db9-cls5   : Generating sosreport...
exascaler-cloud-2db9-cls4   : Retrieving sosreport...
exascaler-cloud-2db9-cls4   : Successfully collected sosreport
exascaler-cloud-2db9-cls6   : Generating sosreport...
exascaler-cloud-2db9-cls5   : Retrieving sosreport...
exascaler-cloud-2db9-cls5   : Successfully collected sosreport
exascaler-cloud-2db9-cls7   : Generating sosreport...
exascaler-cloud-2db9-cls6   : Retrieving sosreport...
exascaler-cloud-2db9-cls6   : Successfully collected sosreport
exascaler-cloud-2db9-cls7   : Retrieving sosreport...
exascaler-cloud-2db9-cls7   : Successfully collected sosreport

Successfully captured 26 of 26 sosreports
Creating archive of sosreports...

The following archive has been created. Please provide it to your support team.
    /var/tmp/sos-collector-2021-12-01-lyowl.tar.gz
```

## Destroy the EXAScaler Cloud environment

The `terraform destroy` command is a convenient way to destroy all remote objects managed by a particular Terraform configuration:
```shell
terraform destroy
```

Output:
```shell
$ terraform destroy
 ...
  Enter a value: yes
 ...
Destroy complete! Resources: 200 destroyed.
```
