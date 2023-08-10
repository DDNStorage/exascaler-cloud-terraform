# Terraform scripts for EXAScaler Cloud on Microsoft Azure

  * [Supported products](#supported-products)
  * [Client packages](#client-packages)
  * [Prerequisites](#prerequisites)
  * [Steps to authenticate via Microsoft account](#steps-to-authenticate-via-microsoft-account)
  * [Steps to accept the terms of use for DDN EXAScaler Cloud images](#steps-to-accept-the-terms-of-use-for-ddn-exascaler-cloud-images)
  * [Steps to configure Terraform](#steps-to-configure-terraform)
    + [List of available variables](#list-of-available-variables)
      - [Common options](#common-options)
      - [Availability options](#availability-options)
      - [Resource group options](#resource-group-options)
      - [Proximity placement group options](#proximity-placement-group-options)
      - [Network options](#network-options)
      - [Subnet options](#subnet-options)
      - [Security options](#security-options)
      - [Boot disk options](#boot-disk-options)
      - [Source image options](#source-image-options)
      - [Storage account options](#storage-account-options)
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
  * [Steps to destroy the EXAScaler Cloud environment](#steps-to-destroy-the-exascaler-cloud-environment)
  * [Run benchmarks](#run-benchmarks)
  * [Install new EXAScaler Cloud clients](#install-new-exascaler-cloud-clients)
  * [Client-side encryption](#client-side-encryption)
  * [Collect inventory and support bundle](#collect-inventory-and-support-bundle)

The steps below will show how to create a EXAScaler Cloud environment on Microsoft Azure using Terraform.

## Supported products

| Product         | Version | Base OS Vendor and Version   | Stock Keeping Unit (`SKU`)   |
| --------------- | ------- | ---------------------------- | ---------------------------- |
| EXAScaler Cloud | 5.2.6   | Red Hat Enterprise Linux 7.9 | `exascaler_cloud_5_2_redhat` |
| EXAScaler Cloud | 5.2.6   | CentOS Linux 7.9             | `exascaler_cloud_5_2_centos` |
| EXAScaler Cloud | 6.1.0   | Red Hat Enterprise Linux 7.9 | `exascaler_cloud_6_1_redhat` |
| EXAScaler Cloud | 6.1.0   | CentOS Linux 7.9             | `exascaler_cloud_6_1_centos` |
| EXAScaler Cloud | 6.2.0   | Red Hat Enterprise Linux 8.7 | `exascaler_cloud_6_2_redhat` |
| EXAScaler Cloud | 6.2.0   | Rocky Linux 8.7              | `exascaler_cloud_6_2_rocky`  |

## Client packages

EXAScaler Cloud deployment provides support for installing and configuring third-party clients.
EXAScaler Cloud client software comprises a set of kernel modules which must be compatible with the running kernel, as well as userspace tools for interacting with the filesystem.

| OS Vendor | OS Version       | Kernel Version for binary package | Kernel Version for DKMS package |
| --------- | ---------------- | --------------------------------- | ------------------------------- |
| Red Hat   | RHEL 7.6         | `3.10.0-957.99.1.el7.x86_64`      | `3.10.0`                        |
| Red Hat   | RHEL 7.7         | `3.10.0-1062.71.1.el7.x86_64`     | `3.10.0`                        |
| Red Hat   | RHEL 7.8         | `3.10.0-1127.19.1.el7.x86_64`     | `3.10.0`                        |
| Red Hat   | RHEL 7.9         | `3.10.0-1160.90.1.el7.x86_64`     | `3.10.0`                        |
| Red Hat   | RHEL 8.0         | `4.18.0-80.31.1.el8_0.x86_64`     | `4.18.0`                        |
| Red Hat   | RHEL 8.1         | `4.18.0-147.83.1.el8_1.x86_64`    | `4.18.0`                        |
| Red Hat   | RHEL 8.2         | `4.18.0-193.105.1.el8_2.x86_64`   | `4.18.0`                        |
| Red Hat   | RHEL 8.3         | `4.18.0-240.22.1.el8_3.x86_64`    | `4.18.0`                        |
| Red Hat   | RHEL 8.4         | `4.18.0-305.88.1.el8_4.x86_64`    | `4.18.0`                        |
| Red Hat   | RHEL 8.5         | `4.18.0-348.23.1.el8_5.x86_64`    | `4.18.0`                        |
| Red Hat   | RHEL 8.6         | `4.18.0-372.52.1.el8_6.x86_64`    | `4.18.0`                        |
| Red Hat   | RHEL 8.7         | `4.18.0-425.19.2.el8_7.x86_64`    | `4.18.0`                        |
| Red Hat   | RHEL 8.8         | `4.18.0-477.10.1.el8_8.x86_64`    | `4.18.0`                        |
| Red Hat   | RHEL 9.0         | `5.14.0-70.53.1.el9_0.x86_64`     | `5.14.0`                        |
| Red Hat   | RHEL 9.1         | `5.14.0-162.23.1.el9_1.x86_64`    | `5.14.0`                        |
| Red Hat   | RHEL 9.2         | `5.14.0-284.11.1.el9_2.x86_64`    | `5.14.0`                        |
| Canonical | Ubuntu 16.04 LTS | —                                 | `4.4 - 4.15`                    |
| Canonical | Ubuntu 18.04 LTS | —                                 | `4.15 - 5.4`                    |
| Canonical | Ubuntu 20.04 LTS | —                                 | `5.4 - 5.15`                    |
| Canonical | Ubuntu 22.04 LTS | —                                 | `5.15 - 5.18`                   |

## Prerequisites

* You need a [Microsoft](https://login.microsoftonline.com) account
* Your system needs the [Microsoft Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) as well as [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

Before deploy Terraform code for Microsoft Azure, you will need to authenticate under the Microsoft account you used to log into the [Microsoft Azure Portal](https://portal.azure.com). You will use a Microsoft account and its credentials to allow Terraform to deploy resources.

DDN EXAScaler Cloud in the Azure Marketplace have additional license and purchase terms that you must accept before you can deploy them programmatically. To deploy an environment from this image, you'll need to accept the image's terms the first time you use it, once per subscription.

## Steps to authenticate via Microsoft account

Obtains access credentials for your user account via a web-based authorization flow. When this command completes successfully, it sets the active account in the current configuration to the account specified. [Learn more about Azure authentication](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell#authenticate-via-microsoft-account).
```shell
az login
```

Output:
```shell
$ az login
[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "00000000-0000-0000-0000-000000000000",
    "id": "00000000-0000-0000-0000-000000000000",
    "isDefault": true,
    "managedByTenants": [],
    "name": "Subscription-Name",
    "state": "Enabled",
    "tenantId": "00000000-0000-0000-0000-000000000000",
    "user": {
      "name": "user@domain.com",
      "type": "user"
    }
  }
]
```

To view the current Azure subscription ID, please use [az account show](https://docs.microsoft.com/en-us/cli/azure/account#az_account_show).
```shell
az account show
```

Output:
```shell
$ az account show
{
  "environmentName": "AzureCloud",
  "homeTenantId": "00000000-0000-0000-0000-000000000000",
  "id": "00000000-0000-0000-0000-000000000000",
  "isDefault": true,
  "managedByTenants": [],
  "name": "Subscription-Name",
  "state": "Enabled",
  "tenantId": "00000000-0000-0000-0000-000000000000",
  "user": {
    "name": "user@domain.com",
    "type": "user"
  }
}
```
Please use the value of `id` property as an Azure subscription ID for Terraform based deployments.

## Steps to accept the terms of use for DDN EXAScaler Cloud images

To deploy DDN EXAScaler Cloud, you need to accept the Azure Marketplace image terms so that the image can be used to create a deployment.

* For EXAScaler Cloud 5.2 and CentOS Linux based image:
```shell
az vm image terms accept --urn ddn-whamcloud-5345716:exascaler_cloud:exascaler_cloud_5_2_centos:latest
```

* For EXAScaler Cloud 5.2 and Red Hat Enterprise Linux based image:
```shell
az vm image terms accept --urn ddn-whamcloud-5345716:exascaler_cloud:exascaler_cloud_5_2_redhat:latest
```

* For EXAScaler Cloud 6.1 and CentOS Linux based image:
```shell
az vm image terms accept --urn ddn-whamcloud-5345716:exascaler_cloud:exascaler_cloud_6_1_centos:latest
```

* For EXAScaler Cloud 6.1 and Red Hat Enterprise Linux based image:
```shell
az vm image terms accept --urn ddn-whamcloud-5345716:exascaler_cloud:exascaler_cloud_6_1_redhat:latest
```

* For EXAScaler Cloud 6.2 and Rocky Linux based image:
```shell
az vm image terms accept --urn ddn-whamcloud-5345716:exascaler_cloud:exascaler_cloud_6_2_rocky:latest
```

* For EXAScaler Cloud 6.2 and Red Hat Enterprise Linux based image:
```shell
az vm image terms accept --urn ddn-whamcloud-5345716:exascaler_cloud:exascaler_cloud_6_2_redhat:latest
```

[Learn more about the image terms](https://mpcprodsa.blob.core.windows.net/legalterms/3E5ED_legalterms_DDN%253a2DWHAMCLOUD%253a2D5345716%253a24EXASCALER%253a5FCLOUD%253a24EXASCALER%253a5F520%253a24RI46C54X4ZEJTZXVGNKQTMOOLKIMCBELLB75XRKMA6KZU63OEITXAF4VOL2MD4M4BTNGHGCYM4NAH2P7REASLOTOHK72WYRNBCHH5WI.txt).

## Steps to configure Terraform

Download Terraform [scripts](https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/2.1.8.tar.gz) and extract the [tarball](https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/2.1.8.tar.gz):
```shell
curl -sL https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/2.1.8.tar.gz | tar xz
```

Change Terraform variables according you requirements:
```shell
cd exascaler-cloud-terraform-scripts-2.1.8/az
vi terraform.tfvars
```

### List of available variables

#### Common options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `prefix` | `string` | `null`     | EXAScaler Cloud custom deployment prefix. Set this option to add a custom prefix to all created objects. |
| `tags`   | `map`    | `{}`       | EXAScaler Cloud custom deployment tags. Set this option to add a custom tags to all created objects. [Learn more about Azure tags](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources). |
| `fsname` | `string` | `exacloud` | EXAScaler filesystem name. [Learn more about Lustre filesystem](https://github.com/DDNStorage/lustre_manual_markdown/blob/master/03.02-Lustre%20Operations.md#mounting-by-label).|
| `subscription` | `string` | `00000000-0000-0000-0000-000000000000` | Subscription ID - please use ID of you active Azure subscription. [Learn more Azure subscriptions](https://docs.microsoft.com/azure/azure-portal/get-subscription-tenant-id). |
| `location` | `string` | `West US` | Azure region to manage resources. [Learn more about Azure geography](https://azure.microsoft.com/global-infrastructure/geographies). |

#### Availability options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `availability.type` | `string` | `none` | Availability type: `none` - no infrastructure redundancy required, `set` - to create an availability set and automatically distribute resources across multiple fault domains, `zone` - to physically separate resources within an Azure region. [Learn more about Azure availability options](https://docs.microsoft.com/azure/virtual-machines/availability). |
| `availability.zone` | `integer` | `1` | Availability zone - unique physical locations within a Azure region. Use `1`, `2` or `3` to explicitly specify the availability zone. [Learn more about Azure availability zones](https://docs.microsoft.com/azure/availability-zones). |

#### Resource group options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `resource_group.new` | `bool` | `true` | Create a new resource group, or use an existing one: `true` or `false`. |
|`resource_group.name` | `string` | `existing-resource-group` | Existing resource group name, will be using if `new` is `false`. |

[Learn more about Azure resource groups](https://docs.microsoft.com/azure/azure-resource-manager/management/manage-resource-groups-portal).

#### Proximity placement group options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `proximity_placement_group.new` | `bool` | `true` | Create a new proximity placement group, or use an existing one: `true` or `false`.|
| `proximity_placement_group.name` | `string` | `existing-proximity-placement-group` | Existing proximity placement group name, will be using if new is `false`. |

[Learn more about Azure proximity placement groups](https://azure.microsoft.com/blog/introducing-proximity-placement-groups).

#### Network options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `network.new` | `bool` | `true` | Create a new network, or use an existing one: `true` or `false`. |
| `network.name` | `string` | `existing-network` | Existing network name, will be using only if `new` option is `false`. |
| `network.address` | `string` | `10.0.0.0/8` | IP address in CIDR notation for the new virtual network. |

[Learn more about Azure virtual networks](https://docs.microsoft.com/azure/virtual-network/virtual-networks-overview).

#### Subnet options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `subnet.new` | `bool` | `true` | Create a new subnet, or use an existing one: `true` or `false`. |
| `subnet.name` | `string` | `existing-subnet` | Existing subnet name, will be using only if `new` option is `false`. |
| `network.address` | `string` | `10.0.0.0/24` | IP address in CIDR notation for the new subnet. |

[Learn more about Azure virtual networks and subnets](https://docs.microsoft.com/azure/virtual-network/virtual-networks-overview).

#### Security options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `security.username` | `string` | `stack` | User name for remote SSH access. [Learn more about Azure SSH options](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed). |
| `security.ssh_public_key` | `string` | `~/.ssh/id_rsa.pub` | Path to the local SSH public key. This file will be added to admin home directory as `.ssh/authorized_keys`. [Learn more about Azure SSH options](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed). |
| `security.enable_ssh` | `bool` | `true` | `true` or `false`: enable or disable remote SSH access. |
| `security.enable_http` | `bool` | `true` | `true` or `false`, enable or disable remote HTTP access. |
| `security.ssh_source_ranges` | `list(string)` | `[0.0.0.0/0]` | Source IP ranges for remote SSH access in CIDR notation. [Learn more about Azure network security groups](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview). |
| `security.http_source_ranges` | `list(string)` | `[0.0.0.0/0]` | Source IP ranges for remote HTTP access in CIDR notation. [Learn more Azure network security groups](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview). |

#### Boot disk options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `boot.disk_type` | `string` | `StandardSSD_LRS` | Specifies the type of managed disk to create: <ul><li>`Standard_LRS`</li><li>`Premium_LRS`</li><li>`StandardSSD_LRS`</li></ul> |
| `boot.disk_cache` | `string` | `ReadWrite` | Specifies the caching requirements for the target disk: <ul><li>`None`</li><li>`ReadOnly`</li><li>`ReadWrite`</li></ul> |
| `boot.auto_delete` | `bool` | `true` | Delete the boot disk automatically when deleting the virtual machine: `true` or `false`. |
| `boot.disk_size` | `integer` | `64` | Boot disk size in GB. |

[Learn more about Azure disks types](https://docs.microsoft.com/azure/virtual-machines/disks-types).

#### Source image options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `image.publisher` | `string` | `ddn-whamcloud-5345716` | Specifies the publisher of the image used to create the virtual machine. |
| `image.offer` | `string` | `exascaler_cloud` | Specifies the offer of the image used to create the virtual machine. |
| `image.sku` | `string` | `exascaler_cloud_6_2_rocky` | Specifies the `SKU` of the image used to create the virtual machine. EXAScaler Cloud 5.2 images: <ul><li>`exascaler_cloud_5_2_centos`</li><li>`exascaler_cloud_5_2_redhat`</li></ul>EXAScaler Cloud 6.1 images: <ul><li>`exascaler_cloud_6_1_centos`</li><li>`exascaler_cloud_6_1_redhat`</li></ul>EXAScaler Cloud 6.2 images: <ul><li>`exascaler_cloud_6_2_rocky`</li><li>`exascaler_cloud_6_2_redhat`</li></ul> |
| `image.version` | `string` | `latest` | Specifies the version of the image used to create the virtual machine. |
| `image.accept`  | `bool` | `false` | Allows automatically accepting the legal terms for a Marketplace image. |

[Learn more about Azure disk images](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/imaging).

#### Storage account options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `storage_account.kind` | `string` | `StorageV2` | Defines the kind of account. Valid options are: <ul><li>`BlobStorage`</li><li>`BlockBlobStorage`</li><li>`FileStorage`</li><li>`Storage`</li><li>`StorageV2`</li></ul> |
| `storage_account.tier` | `string` | `Standard` | Defines the tier to use for this storage account. Valid options are: <ul><li>`Standard`</li><li>`Premium`</li></ul> |
| `storage_account.replication` | `string` | `LRS` | Defines the type of replication to use for this storage account. Valid options are: <ul><li>`LRS`</li><li>`GRS`</li><li>`RAGRS`</li><li>`ZRS`</li><li>`GZRS`</li><li>`RAGZRS`</li></ul> |

[Learn more about Azure storage accounts](https://docs.microsoft.com/azure/storage/common/storage-account-overview).

#### Management server options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `mgs.node_type` | `string` | `Standard_F4s` | Type of management server. [Learn more about Azure performance considerations](https://docs.microsoft.com/azure/cloud-services/cloud-services-sizes-specs). |
| `mgs.node_count` | `integer` | `1` | Number of management servers: `1`. |
| `mgs.public_ip` | `bool` | `true` | Assign a public IP address: `true` or `false`. [Learn more about Azure public IP addresses](https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses). |
| `mgs.accelerated_network` | `bool` | `false` | Enable accelerated networking. [Learn more about Azure accelerated networking](https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli). |

#### Management target options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `mgt.disk_type` | `string` | `StandardSSD_LRS` | Specifies the type of managed disk to create the management target: <ul><li>`Standard_LRS`</li><li>`StandardSSD_LRS`</li><li>`Premium_LRS`</li></ul> |
| `mgt.disk_cache` | `string` | `None` | Specifies the caching requirements for the management target: <ul><li>`None`</li><li>`ReadOnly`</li><li>`ReadWrite`</li></ul> |
| `mgt.disk_size` | `integer` | `256` | Specifies the size of the management target in GB. |
| `mgt.disk_count` | `integer` | `1` | Specifies the number of management targets: `1-128`. |
| `mgt.disk_raid` | `bool` | `false` | Create striped management target: `true` or `false`. |

[Learn more about Azure disks types](https://docs.microsoft.com/azure/virtual-machines/disks-types)

#### Monitoring target options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `mnt.disk_type` | `string` | `StandardSSD_LRS` | Specifies the type of managed disk to create the monitoring target: <ul><li>`Standard_LRS`</li><li>`StandardSSD_LRS`</li><li>`Premium_LRS`</li></ul> |
| `mnt.disk_cache` | `string` | `None` | Specifies the caching requirements for the monitoring target: <ul><li>`None`</li><li>`ReadOnly`</li><li>`ReadWrite`</li></ul> |
| `mnt.disk_size` | `integer` | `128` | Specifies the size of the monitoring target in GB. |
| `mnt.disk_count` | `integer` | `1` | Specifies the number of monitoring targets: `1-128`. |
| `mnt.disk_raid` | `bool` | `false` | Create striped monitoring target: `true` or `false`. |

[Learn more about Azure disks types](https://docs.microsoft.com/azure/virtual-machines/disks-types)

#### Metadata server options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `mds.node_type` | `string` | `Standard_E8s_v3` | Type of metadata server. [Learn more about Azure performance considerations](https://docs.microsoft.com/azure/cloud-services/cloud-services-sizes-specs). |
| `mds.node_count` | `integer` | `1` | Number of metadata servers: `1-32`. |
| `mds.public_ip` | `bool` | `false` | Assign a public IP address: `true` or `false`. [Learn more about Azure public IP addresses](https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses). |
| `mds.accelerated_network` | `bool` | `false` | Enable accelerated networking. [Learn more about Azure accelerated networking](https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli). |

#### Metadata target options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `mdt.disk_type` | `string` | `Premium_LRS` | Specifies the type of managed disk to create the metadata target: <ul><li>`Standard_LRS`</li><li>`StandardSSD_LRS`</li><li>`Premium_LRS`</li></ul> |
| `mdt.disk_cache` | `string` | `None` | Specifies the caching requirements for the metadata target: <ul><li>`None`</li><li>`ReadOnly`</li><li>`ReadWrite`</li></ul> |
| `mdt.disk_size` | `integer` | `512` | Specifies the size of the metadata target in GB. |
| `mdt.disk_count` | `integer` | `1` | Specifies the number of metadata targets: `1-128`. |
| `mdt.disk_raid` | `bool` | `false` | Create striped metadata target: `true` or `false`. |

[Learn more about Azure disks types](https://docs.microsoft.com/azure/virtual-machines/disks-types)

#### Object Storage server options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `oss.node_type` | `string` | `Standard_Ds16_v3` | Type of object storage server. [Learn more about Azure performance considerations](https://docs.microsoft.com/azure/cloud-services/cloud-services-sizes-specs). |
| `oss.node_count` | `integer` | `4` | Number of object storage servers: `1-2000`. |
| `oss.public_ip` | `bool` | `false` | Assign a public IP address: `true` or `false`. [Learn more about Azure public IP addresses](https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses). |
| `oss.accelerated_network` | `bool` | `false` | Enable accelerated networking. [Learn more about Azure accelerated networking](https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli). |

#### Object Storage target options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `ost.disk_type` | `string` | `Standard_LRS` | Specifies the type of managed disk to create the object storage target: <ul><li>`Standard_LRS`</li><li>`StandardSSD_LRS`</li><li>`Premium_LRS`</li></ul> |
| `ost.disk_cache` | `string` | `None` | Specifies the caching requirements for the object storage target: <ul><li>`None`</li><li>`ReadOnly`</li><li>`ReadWrite`</li></ul> |
| `ost.disk_size` | `integer` | `512` | Specifies the size of the object storage target in GB. |
| `ost.disk_count` | `integer` | `6` | Specifies the number of object storage targets: `1-128`. |
| `ost.disk_raid` | `bool` | `false` | Create striped object storage target: `true` or `false`. |

[Learn more about Azure disks types](https://docs.microsoft.com/azure/virtual-machines/disks-types)

#### Compute client options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `cls.node_type` | `string` | `Standard_Ds16_v3` | Type of compute client. [Learn more about Azure performance considerations](https://docs.microsoft.com/azure/cloud-services/cloud-services-sizes-specs). |
| `cls.node_count` | `integer` | `4` | Number of compute clients. |
| `cls.public_ip` | `bool` | `false` | Assign a public IP address: `true` or `false`. [Learn more about Azure public IP addresses](https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses). |
| `cls.accelerated_network` | `bool` | `false` | Enable accelerated networking. [Learn more about Azure accelerated networking](https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli). |

#### Compute client target options
| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `clt.disk_type` | `string` | `Standard_LRS` | Specifies the type of managed disk to create the compute target: <ul><li>`Standard_LRS`</li><li>`StandardSSD_LRS`</li><li>`Premium_LRS`</li></ul> |
| `clt.disk_cache` | `string` | `None` | Specifies the caching requirements for the compute target: <ul><li>`None`</li><li>`ReadOnly`</li><li>`ReadWrite`</li></ul> |
| `clt.disk_size` | `integer` | `32` | Specifies the size of the compute target in GB. |
| `clt.disk_count` | `integer` | `0` | Specifies the number of compute targets. |

[Learn more about Azure disks types](https://docs.microsoft.com/azure/virtual-machines/disks-types)


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
- Finding hashicorp/azurerm versions matching ">= 3.10.0"...
- Finding latest version of hashicorp/random...
- Finding latest version of hashicorp/template...
- Installing hashicorp/azurerm v3.13.0...
- Installed hashicorp/azurerm v3.13.0 (signed by HashiCorp)
- Installing hashicorp/random v3.3.2...
- Installed hashicorp/random v3.3.2 (signed by HashiCorp)
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
  Enter a value: yes
...
Apply complete! Resources: 103 added, 0 changed, 0 destroyed.

Outputs:

azure_dashboard = "https://portal.azure.com/#@00000000-0000-0000-0000-000000000000/dashboard/arm/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/exascaler-cloud-a108-resource-group/providers/Microsoft.Portal/dashboards/exascaler-cloud-a108-dashboard"

client_config = <<EOT
#!/bin/sh
# install new EXAScaler Cloud clients:
# all instances must be in the same location westus
# and connected to the network exascaler-cloud-a108-virtual-network
# and subnet exascaler-cloud-a108-subnet
# to set up EXAScaler Cloud filesystem on a new client instance,
# run the folowing commands on the client with root privileges:

cat >/etc/esc-client.conf<<EOF
{
  "Version": "2.1.0",
  "MountConfig": {
    "ClientDevice": "10.0.0.10@tcp:/exacloud",
    "Mountpoint": "/mnt/exacloud",
    "PackageSource": "http://10.0.0.10/client-packages"
  }
}
EOF

curl -fsSL http://10.0.0.10/client-setup-tool -o /usr/sbin/esc-client
chmod +x /usr/sbin/esc-client
esc-client auto setup --config /etc/esc-client.conf

EOT

http_console = "http://exascaler-cloud-a108-mgs0.westus.cloudapp.azure.com"

mount_command = "mount -t lustre 10.0.0.10@tcp:/exacloud /mnt/exacloud"

private_addresses = {
  "exascaler-cloud-a108-cls0" = "10.0.0.8"
  "exascaler-cloud-a108-cls1" = "10.0.0.7"
  "exascaler-cloud-a108-cls2" = "10.0.0.11"
  "exascaler-cloud-a108-cls3" = "10.0.0.12"
  "exascaler-cloud-a108-mds0" = "10.0.0.13"
  "exascaler-cloud-a108-mgs0" = "10.0.0.10"
  "exascaler-cloud-a108-oss0" = "10.0.0.9"
  "exascaler-cloud-a108-oss1" = "10.0.0.4"
  "exascaler-cloud-a108-oss2" = "10.0.0.5"
  "exascaler-cloud-a108-oss3" = "10.0.0.6"
}

ssh_console = {
  "exascaler-cloud-a108-mgs0" = "ssh -A stack@exascaler-cloud-a108-mgs0.westus.cloud
app.azure.com"
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
Agent pid 12313

$ ssh-add
Identity added: /Users/name/.ssh/id_rsa (/Users/name/.ssh/id_rsa)

$ ssh -A stack@exascaler-cloud-a108-mgs0.westus.cloudapp.azure.com

[stack@exascaler-cloud-a108-mgs0 ~]$ df -h -t lustre
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdc        249G  2.4M  247G   1% /mnt/targets/MGS

[stack@exascaler-cloud-a108-mgs0 ~]$ loci hosts
10.0.0.8	exascaler-cloud-a108-cls0
10.0.0.7	exascaler-cloud-a108-cls1
10.0.0.11	exascaler-cloud-a108-cls2
10.0.0.12	exascaler-cloud-a108-cls3
10.0.0.13	exascaler-cloud-a108-mds0
10.0.0.10	exascaler-cloud-a108-mgs0
10.0.0.9	exascaler-cloud-a108-oss0
10.0.0.4	exascaler-cloud-a108-oss1
10.0.0.5	exascaler-cloud-a108-oss2
10.0.0.6	exascaler-cloud-a108-oss3

[stack@exascaler-cloud-a108-mgs0 ~]$ ssh exascaler-cloud-a108-cls0

[stack@exascaler-cloud-a108-cls0 ~]$ lfs df
UUID                   1K-blocks        Used   Available Use% Mounted on
exacloud-MDT0000_UUID   315302464        6212   309927544   1% /mnt/exacloud[MDT:0]
exacloud-OST0000_UUID   529449792        1256   524063444   1% /mnt/exacloud[OST:0]
exacloud-OST0001_UUID   529449792        1272   524063428   1% /mnt/exacloud[OST:1]
exacloud-OST0002_UUID   529449792        1268   524063432   1% /mnt/exacloud[OST:2]
exacloud-OST0003_UUID   529449792        1264   524063436   1% /mnt/exacloud[OST:3]
exacloud-OST0004_UUID   529449792        1256   524063444   1% /mnt/exacloud[OST:4]
exacloud-OST0005_UUID   529449792        1264   524063436   1% /mnt/exacloud[OST:5]
exacloud-OST0006_UUID   529449792        1276   524063424   1% /mnt/exacloud[OST:6]
exacloud-OST0007_UUID   529449792        1268   524063432   1% /mnt/exacloud[OST:7]
exacloud-OST0008_UUID   529449792        1260   524063440   1% /mnt/exacloud[OST:8]
exacloud-OST0009_UUID   529449792        1272   524063428   1% /mnt/exacloud[OST:9]
exacloud-OST000a_UUID   529449792        1268   524063432   1% /mnt/exacloud[OST:10]
exacloud-OST000b_UUID   529449792        1272   524063428   1% /mnt/exacloud[OST:11]
exacloud-OST000c_UUID   529449792        1256   524063444   1% /mnt/exacloud[OST:12]
exacloud-OST000d_UUID   529449792        1264   524063436   1% /mnt/exacloud[OST:13]
exacloud-OST000e_UUID   529449792        1268   524063432   1% /mnt/exacloud[OST:14]
exacloud-OST000f_UUID   529449792        1260   524063440   1% /mnt/exacloud[OST:15]
exacloud-OST0010_UUID   529449792        1272   524063428   1% /mnt/exacloud[OST:16]
exacloud-OST0011_UUID   529449792        1260   524063440   1% /mnt/exacloud[OST:17]
exacloud-OST0012_UUID   529449792        1256   524063444   1% /mnt/exacloud[OST:18]
exacloud-OST0013_UUID   529449792        1264   524063436   1% /mnt/exacloud[OST:19]
exacloud-OST0014_UUID   529449792        1256   524063444   1% /mnt/exacloud[OST:20]
exacloud-OST0015_UUID   529449792        1260   524063440   1% /mnt/exacloud[OST:21]
exacloud-OST0016_UUID   529449792        1272   524063428   1% /mnt/exacloud[OST:22]
exacloud-OST0017_UUID   529449792        1264   524063436   1% /mnt/exacloud[OST:23]

filesystem_summary:  12706795008       30348 12577522452   1% /mnt/exacloud
```

## Add storage capacity in an existing EXAScaler Cloud environment

The storage capacity can be added by increasing the number of storage servers.
To add storage capacity in an existing EXAScaler Cloud environment, just modify the `terraform.tfvars` file and increase the number of storage servers (the value of the `oss.node_count` variable) as required:
```
$ diff -u terraform.tfvars.orig terraform.tfvars
@@ -217,7 +217,7 @@
 oss = {
   node_type           = "Standard_D16s_v3"
-  node_count          = 6
+  node_count          = 12
   public_ip           = false
   accelerated_network = true
 }
```

And then run the `terraform apply` command to increase the storage capacity.
The available storage capacity (in GB) can be calculated by multiplying the three configuration parameters:
```
capacity = oss.node_count * ost.disk_count * ost.disk_size
```

## Upgrade an existing EXAScaler Cloud environment

A software upgrade for an existing EXAScaler Cloud environment is possible by recreating the running VM instances using a new version of the OS image. And it requires some manual steps.

Create a backup copy for the existing Terraform directory (\*.tf, terraform.tfvars and terraform.tfstate files):
```shell
cd /path/to/exascaler-cloud-terraform-scripts-x.y.z/az
tar pcfz backup.tgz *.tf terraform.tfvars terraform.tfstate
```

Update Terraform scripts using the latest available EXAScaler Cloud Terraform [scripts](https://github.com/DDNStorage/exascaler-cloud-terraform):
```shell
cd /path/to
curl -sL https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/2.1.8.tar.gz | tar xz
cd exascaler-cloud-terraform-scripts-2.1.8/az
```

Copy the terraform.tfstate file from the existing Terraform directory:
```shell
cp -iv /path/to/exascaler-cloud-terraform-scripts-x.y.z/az/terraform.tfstate .
```

Review and update the terraform.tfvars file using configuration options for the existing environment:
```shell
diff -u  /path/to/exascaler-cloud-terraform-scripts-x.y.z/az/terraform.tfvars terraform.tfvars
vi terraform.tfvars
```

Review the execution plan to make sure all changes are expected:
```shell
terraform plan
```

Unmount the existing EXAScaler Cloud filesystem using the provided [esc-ctl](https://github.com/DDNStorage/exascaler-cloud-terraform/az/scripts/esc-ctl) script. This step is required to ensure data consistency during the upgrade:
```shell
$ ./scripts/esc-ctl

Usage:

List resource groups : ./scripts/esc-ctl list
List deployments     : ./scripts/esc-ctl <resource_group> list
List instances       : ./scripts/esc-ctl <resource_group> <deployment> list
Stop instances       : ./scripts/esc-ctl <resource_group> <deployment> stop
Start instances      : ./scripts/esc-ctl <resource_group> <deployment> start
Unmount filesystem   : ./scripts/esc-ctl <resource_group> <deployment> umount

$ ./scripts/esc-ctl list
Name                                 Location    Status
-----------------------------------  ----------  ---------
exascaler-cloud-f7cd-resource-group  eastus      Succeeded
NetworkWatcherRG                     westus      Succeeded

$ ./scripts/esc-ctl exascaler-cloud-f7cd-resource-group list
Name                            Created                    Status
------------------------------  -------------------------  ---------
exascaler-cloud-f7cd            2021-08-21T01:19:36+00:00  Succeeded

$ ./scripts/esc-ctl exascaler-cloud-f7cd-resource-group exascaler-cloud-f7cd umount
Umount compute client exascaler-cloud-f7cd-cls0
Umount compute client exascaler-cloud-f7cd-cls1
Umount storage server exascaler-cloud-f7cd-oss0
Umount storage server exascaler-cloud-f7cd-oss1
Umount storage server exascaler-cloud-f7cd-oss2
Umount storage server exascaler-cloud-f7cd-oss3
Umount metadata server exascaler-cloud-f7cd-mds0
Umount management server exascaler-cloud-f7cd-mgs0
```

Apply the changes required to upgrade the existing EXAScaler Cloud environment by recreating all instances using the latest version of EXAScaler Cloud:
```
$ terraform apply
...
  Enter a value: yes
...

Outputs:

Apply complete! Resources: 18 added, 8 changed, 16 destroyed.

Outputs:

azure_dashboard = "https://portal.azure.com/#@753b6e26-6fd3-43e6-8248-3f1735d59bb4/dashboard/arm/subscriptions/9978cd1b-936a-4296-8061-67c9d963dd40/resourceGroups/exascaler-cloud-f7cd-resource-group/providers/Microsoft.Portal/dashboards/exascaler-cloud-f7cd-dashboard"

http_console = "http://exascaler-cloud-f7cd-mgs0.eastus.cloudapp.azure.com"

mount_command = "mount -t lustre 10.0.0.11@tcp:/exacloud /mnt/exacloud"

private_addresses = {
  "exascaler-cloud-f7cd-cls0" = "10.0.0.6"
  "exascaler-cloud-f7cd-cls1" = "10.0.0.7"
  "exascaler-cloud-f7cd-mds0" = "10.0.0.8"
  "exascaler-cloud-f7cd-mgs0" = "10.0.0.11"
  "exascaler-cloud-f7cd-oss0" = "10.0.0.9"
  "exascaler-cloud-f7cd-oss1" = "10.0.0.4"
  "exascaler-cloud-f7cd-oss2" = "10.0.0.10"
  "exascaler-cloud-f7cd-oss3" = "10.0.0.5"
}

ssh_console = {
  "exascaler-cloud-f7cd-mgs0" = "ssh -A stack@exascaler-cloud-f7cd-mgs0.eastus.cloudapp.azure.com"
}
```

## Steps to destroy the EXAScaler Cloud environment

Destroy the EXAScaler Cloud environment:
```shell
terraform destroy
```

Output:
```shell
$ terraform destroy
...
  Enter a value: yes
...
Destroy complete! Resources: 103 destroyed.
```

## Run benchmarks

### Steps to run [IOR](https://ior.readthedocs.io) benchmark on the EXAScaler Cloud deployment:

* Run [ssh-agent](https://linux.die.net/man/1/ssh-agent)
* Add [ssh private key](https://linux.die.net/man/1/ssh-add)
* Open an SSH session to the EXAScaler Cloud management server
* Run [IOR](https://wiki.lustre.org/IOR) benchmark using `esc-ior` tool

```shell
eval $(ssh-agent)
ssh-add
ssh -A stack@exascaler-cloud-a108-mgs0.westus.cloudapp.azure.com
esc-ior
```

Output:
```shell
$ eval $(ssh-agent)
Agent pid 18111

$ ssh-add
Identity added: /home/user/.ssh/id_rsa

$ ssh -A stack@exascaler-cloud-b59f-mgs0.westus.cloudapp.azure.com

[stack@exascaler-cloud-a108-mgs0 ~]$ esc-ior
IOR-3.3.0: MPI Coordinated Test of Parallel I/O
Began               : Mon Jul 11 12:04:24 2022
Command line        : /usr/bin/ior -C -F -e -r -w -a POSIX -b 16777216 -t 1048576 -s 321 -o /mnt/exacloud/d19aea2d56d13401/d19aea2d56d13401
Machine             : Linux exascaler-cloud-a108-cls0
TestID              : 0
StartTime           : Mon Jul 11 12:04:24 2022
Path                : /mnt/exacloud/d19aea2d56d13401
FS                  : 11.8 TiB   Used FS: 0.0%   Inodes: 96.0 Mi   Used Inodes: 0.0%

Options:
api                 : POSIX
apiVersion          :
test filename       : /mnt/exacloud/d19aea2d56d13401/d19aea2d56d13401
access              : file-per-process
type                : independent
segments            : 321
ordering in a file  : sequential
ordering inter file : constant task offset
task offset         : 1
nodes               : 4
tasks               : 64
clients per node    : 16
repetitions         : 1
xfersize            : 1 MiB
blocksize           : 16 MiB
aggregate filesize  : 321 GiB

Results:

access    bw(MiB/s)  IOPS       Latency(s)  block(KiB) xfer(KiB)  open(s)    wr/rd(s)   close(s)   total(s)   iter
------    ---------  ----       ----------  ---------- ---------  --------   --------   --------   --------   ----
write     1842.29    1842.31    11.00       16384      1024.00    0.020495   178.42     3.90       178.42     0
read      2316.13    2316.15    8.61        16384      1024.00    0.105245   141.92     43.84      141.92     0
remove    -          -          -           -          -          -          -          -          3.08       0
Max Write: 1842.29 MiB/sec (1931.78 MB/sec)
Max Read:  2316.13 MiB/sec (2428.64 MB/sec)

Summary of all tests:
Operation   Max(MiB)   Min(MiB)  Mean(MiB)     StdDev   Max(OPs)   Min(OPs)  Mean(OPs)     StdDev    Mean(s) Stonewall(s) Stonewall(MiB) Test# #Tasks tPN reps fPP reord reordoff reordrand seed segcnt   blksiz    xsize aggs(MiB)   API RefNum
write        1842.29    1842.29    1842.29       0.00    1842.29    1842.29    1842.29       0.00  178.42125         NA            NA     0     64  16    1   1     1        1         0    0    321 16777216  1048576  328704.0 POSIX      0
read         2316.13    2316.13    2316.13       0.00    2316.13    2316.13    2316.13       0.00  141.91957         NA            NA     0     64  16    1   1     1        1         0    0    321 16777216  1048576  328704.0 POSIX      0
Finished            : Mon Jul 11 12:09:48 2022
```

### Steps to run [mdtest](https://wiki.lustre.org/MDTest) benchmark on the EXAScaler Cloud deployment:

* Run [ssh-agent](https://linux.die.net/man/1/ssh-agent)
* Add [ssh private key](https://linux.die.net/man/1/ssh-add)
* Open an SSH session to the EXAScaler Cloud management server
* Run [mdtest](https://wiki.lustre.org/MDTest) benchmark using `esc-mdtest` tool

```shell
eval $(ssh-agent)
ssh-add
ssh -A stack@exascaler-cloud-a108-mgs0.westus.cloudapp.azure.com
esc-mdtest
```

Output:
```shell
$ eval $(ssh-agent)
Agent pid 18111

$ ssh-add
Identity added: /home/user/.ssh/id_rsa

$ ssh -A stack@exascaler-cloud-b59f-mgs0.westus.cloudapp.azure.com

[stack@exascaler-cloud-a108-mgs0 ~]$ esc-mdtest
-- started at 07/11/2022 12:11:32 --

mdtest-3.3.0 was launched with 64 total task(s) on 4 node(s)
Command line used: /usr/bin/mdtest '-n' '2048' '-i' '3' '-d' '/mnt/exacloud/5a7b7a42728be0b5'
Path: /mnt/exacloud
FS: 11.8 TiB   Used FS: 0.0%   Inodes: 96.0 Mi   Used Inodes: 0.0%

64 tasks, 131072 files/directories

SUMMARY rate: (of 3 iterations)
   Operation                      Max            Min           Mean        Std Dev
   ---------                      ---            ---           ----        -------
   Directory creation        :       7345.338       3211.453       5963.545       1945.909
   Directory stat            :       9250.393       8797.425       9009.705        185.725
   Directory removal         :       7433.034       6735.603       7102.357        285.591
   File creation             :       6342.026       3364.939       5258.577       1343.513
   File stat                 :      14300.892      13962.028      14165.403        145.686
   File read                 :      26741.557      26155.602      26512.201        253.745
   File removal              :       7363.456       7059.209       7252.565        136.783
   Tree creation             :        985.125        695.314        819.873        121.763
   Tree removal              :        353.945        328.764        340.779         10.312
-- finished at 07/11/2022 12:17:26 --
```

### Steps to run [IO500](https://io500.org) benchmark on the EXAScaler Cloud deployment:

* Run [ssh-agent](https://linux.die.net/man/1/ssh-agent)
* Add [ssh private key](https://linux.die.net/man/1/ssh-add)
* Open an SSH session to the EXAScaler Cloud management server
* Open an SSH session to the any EXAScaler Cloud compute host
* Run [IO500](https://github.com/IO500/io500) benchmark using `esc-io500` tool

```shell
eval $(ssh-agent)
ssh-add
ssh -A stack@exascaler-cloud-a108-mgs0.westus.cloudapp.azure.com
loci hosts -c
ssh -A exascaler-cloud-a108-cls0
esc-io500
```

Output:
```shell
$ eval $(ssh-agent)
Agent pid 18111

$ ssh-add
Identity added: /home/user/.ssh/id_rsa

$ ssh -A stack@exascaler-cloud-b59f-mgs0.westus.cloudapp.azure.com

[stack@exascaler-cloud-a108-mgs0 ~]$ loci hosts -c
10.0.0.8	exascaler-cloud-a108-cls0
10.0.0.7	exascaler-cloud-a108-cls1
10.0.0.11	exascaler-cloud-a108-cls2
10.0.0.12	exascaler-cloud-a108-cls3

[stack@exascaler-cloud-a108-mgs0 ~]$ ssh -A exascaler-cloud-a108-cls0

[stack@exascaler-cloud-a108-cls0 ~]$ esc-io500
...
Start IO500 benchmark with options:

Data directory:     /mnt/exacloud/400a32038d422e4f/workload
Hosts list:         10.0.0.8,10.0.0.7,10.0.0.11,10.0.0.12
Processes per host: 16
Files per process:  125343
Number of tasks:    64
Number of segments: 91875
Block size:         14092861440
Transfer size:      1048576

IO500 version io500-sc20_v3
[RESULT]       ior-easy-write        2.259563 GiB/s : time 332.503 seconds
[RESULT]    mdtest-easy-write        9.477171 kIOPS : time 318.456 seconds
[RESULT]       ior-hard-write        0.137260 GiB/s : time 394.965 seconds
[RESULT]    mdtest-hard-write        2.256176 kIOPS : time 334.350 seconds
[RESULT]                 find      364.668060 kIOPS : time 10.058 seconds
[RESULT]        ior-easy-read        2.254557 GiB/s : time 333.201 seconds
[RESULT]     mdtest-easy-stat       35.714169 kIOPS : time 82.155 seconds
[RESULT]        ior-hard-read        0.331565 GiB/s : time 163.505 seconds
[RESULT]     mdtest-hard-stat        7.394830 kIOPS : time 98.398 seconds
[RESULT]   mdtest-easy-delete        7.691341 kIOPS : time 381.333 seconds
[RESULT]     mdtest-hard-read        6.271649 kIOPS : time 115.967 seconds
[RESULT]   mdtest-hard-delete        1.722383 kIOPS : time 422.224 seconds
[SCORE] Bandwidth 0.693905 GiB/s : IOPS 10.694340 kiops : TOTAL 2.724124

The result files are stored in the directory: ./results/2022.07.11-12.46.22
Warning: please create a 'system-information.txt' description by
copying the information from https://vi4io.org/io500-info-creator/
‘./io500.sh’ -> ‘./results/2022.07.11-12.46.22/io500.sh’
‘config.ini’ -> ‘./results/2022.07.11-12.46.22/config.ini’
Created result tarball ./results/io500-exascaler-cloud-a108-cls0-2022.07.11-12.46.22.tgz
/mnt/exacloud/400a32038d422e4f/sources/results
2022.07.11-12.46.22  io500-exascaler-cloud-a108-cls0-2022.07.11-12.46.22.tgz
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
ssh -A stack@exascaler-cloud-a108-mgs0.westus.cloudapp.azure.com
about_this_deployment
esc-collector
```

Output:
```shell
$ eval $(ssh-agent)
Agent pid 18111

$ ssh-add
Identity added: /home/user/.ssh/id_rsa

$ ssh -A stack@exascaler-cloud-b59f-mgs0.westus.cloudapp.azure.com

[stack@exascaler-cloud-a108-mgs0 ~]$ about_this_deployment
cloudName: AzurePublicCloud
subscriptionId: 9978cd1b-936a-4296-8061-67c9d963dd40
location: westus
resourceGroupName: exascaler-cloud-a108-resource-group
deployment: exascaler-cloud-a108
filesystem: exacloud
instances:
- hostName: exascaler-cloud-a108-mgs0
  userName: stack
  proximityPlacementGroup: exascaler-cloud-a108-proximity-placement-group
  passwordAuthentication: false
  instanceName: exascaler-cloud-a108-mgs0
  instanceType: Standard_F4s
  role: mgt
  memoryGB: 8
  VCPUs: 4
  IOPS: 12800
  bandwidthMBps: 192
  network:
    interfaces:
    - name: exascaler-cloud-a108-mgs0-network-interface
      acceleratedNetworking: true
      macAddress: 00-0D-3A-38-19-4D
      ipAddresses:
      - privateIpAddress: 10.0.0.10
        publicIpAddress: 20.253.228.215
        subnet: exascaler-cloud-a108-subnet
  storage:
    image:
      name: exascaler-cloud-redhat-20220709221113
    bootDisk:
      caching: ReadWrite
      sizeGB: 64
      name: exascaler-cloud-a108-mgs0-boot-disk
      writeAcceleratorEnabled: false
      tier: StandardSSD_LRS
      type: E6
      IOPS: 500
      bandwidthMBps: 60
    dataDisks:
    - lun: 0
      caching: None
      sizeGB: 256
      name: exascaler-cloud-a108-mgs0-mgt0-disk
      writeAcceleratorEnabled: false
      tier: StandardSSD_LRS
      type: E15
      IOPS: 500
      bandwidthMBps: 60
    - lun: 1
      caching: None
      sizeGB: 128
      name: exascaler-cloud-a108-mgs0-mnt0-disk
      writeAcceleratorEnabled: false
      tier: StandardSSD_LRS
      type: E10
      IOPS: 500
      bandwidthMBps: 60
...

[stack@exascaler-cloud-a108-mgs0 ~]$ esc-collector

sos-collector (version 1.8)

This utility is used to collect sosreports from multiple nodes simultaneously.
It uses OpenSSH's ControlPersist feature to connect to nodes and run commands
remotely. If your system installation of OpenSSH is older than 5.6, please
upgrade.

An archive of sosreport tarballs collected from the nodes will be generated in
/var/tmp/sos-collector-vzhmlT and may be provided to an appropriate support
representative.

The generated archive may contain data considered sensitive and its content
should be reviewed by the originating organization before being passed to any
third party.

No configuration changes will be made to the system running this utility or
remote systems that it connects to.

sos-collector ASSUMES that SSH keys are installed on all nodes unless the
--password option is provided.


The following is a list of nodes to collect from:

	exascaler-cloud-a108-cls0
	exascaler-cloud-a108-cls1
	exascaler-cloud-a108-cls2
	exascaler-cloud-a108-cls3
	exascaler-cloud-a108-mds0
	exascaler-cloud-a108-mgs0
	exascaler-cloud-a108-oss0
	exascaler-cloud-a108-oss1
	exascaler-cloud-a108-oss2
	exascaler-cloud-a108-oss3


Connecting to nodes...

Beginning collection of sosreports from 10 nodes, collecting a maximum of 4 concurrently

exascaler-cloud-a108-mgs0  : Generating sosreport...
exascaler-cloud-a108-mds0  : Generating sosreport...
exascaler-cloud-a108-cls3  : Generating sosreport...
exascaler-cloud-a108-cls0  : Generating sosreport...
exascaler-cloud-a108-mgs0  : Retrieving sosreport...
exascaler-cloud-a108-mgs0  : Successfully collected sosreport
exascaler-cloud-a108-cls1  : Generating sosreport...
exascaler-cloud-a108-cls0  : Retrieving sosreport...
exascaler-cloud-a108-cls0  : Successfully collected sosreport
exascaler-cloud-a108-cls2  : Generating sosreport...
exascaler-cloud-a108-cls3  : Retrieving sosreport...
exascaler-cloud-a108-cls3  : Successfully collected sosreport
exascaler-cloud-a108-oss2  : Generating sosreport...
exascaler-cloud-a108-mds0  : Retrieving sosreport...
exascaler-cloud-a108-mds0  : Successfully collected sosreport
exascaler-cloud-a108-oss3  : Generating sosreport...
exascaler-cloud-a108-cls2  : Retrieving sosreport...
exascaler-cloud-a108-cls2  : Successfully collected sosreport
exascaler-cloud-a108-oss0  : Generating sosreport...
exascaler-cloud-a108-cls1  : Retrieving sosreport...
exascaler-cloud-a108-cls1  : Successfully collected sosreport
exascaler-cloud-a108-oss2  : Retrieving sosreport...
exascaler-cloud-a108-oss1  : Generating sosreport...
exascaler-cloud-a108-oss2  : Successfully collected sosreport
exascaler-cloud-a108-oss3  : Retrieving sosreport...
exascaler-cloud-a108-oss3  : Successfully collected sosreport
exascaler-cloud-a108-oss0  : Retrieving sosreport...
exascaler-cloud-a108-oss0  : Successfully collected sosreport
exascaler-cloud-a108-oss1  : Retrieving sosreport...
exascaler-cloud-a108-oss1  : Successfully collected sosreport

Successfully captured 10 of 10 sosreports
Creating archive of sosreports...

The following archive has been created. Please provide it to your support team.
    /var/tmp/sos-collector-2022-07-11-ttybt.tar.gz
```
