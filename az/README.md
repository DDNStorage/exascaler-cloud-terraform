# Terraform scripts for EXAScaler Cloud on Microsoft Azure

The steps below will show how to create a EXAScaler Cloud environment on Microsoft Azure using Terraform.

## Prerequisites

* You need a [Microsoft](https://login.microsoftonline.com) account
* Your system needs the [Microsoft Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) as well as [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

Before deploy Terraform code for Microsoft Azure, you will need to authenticate under the Microsoft account you used to log into the [Microsoft Azure Portal](https://portal.azure.com). You will use a Microsoft account and its credentials to allow Terraform to deploy resources.

DDN EXAScaler Cloud in the Azure Marketplace have additional license and purchase terms that you must accept before you can deploy them programmatically. To deploy an environment from this image, you'll need to accept the image's terms the first time you use it, once per subscription.

## Steps to authenticate via Microsoft account

Obtains access credentials for your user account via a web-based authorization flow. When this command completes successfully, it sets the active account in the current configuration to the account specified. [Learn more](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell#authenticate-via-microsoft-account).
```
$ az login
```

To view the current Azure subscription ID, please use [az account show](https://docs.microsoft.com/en-us/cli/azure/account#az_account_show).
```
$ az account show
{
  "environmentName": "AzureCloud",
  "homeTenantId": "00000000-0000-0000-0000-000000000000",
  "id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
  "isDefault": true,
  "managedByTenants": [],
  "name": "Pay-As-You-Go",
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
* For EXAScaler Cloud Red Hat Enterprise Linux based image:
```
$ az vm image terms accept --urn ddn-whamcloud-5345716:exascaler_cloud:exascaler_cloud_523_redhat:5.2.3
{
  "accepted": true,
  "id": "/subscriptions/9978cd1b-936a-4296-8061-67c9d963dd40/providers/Microsoft.MarketplaceOrdering/offerTypes/Microsoft.MarketplaceOrdering/offertypes/publishers/ddn-whamcloud-5345716/offers/exascaler_cloud/plans/exascaler_cloud_523_redhat/agreements/current",
  "licenseTextLink": "https://mpcprodsa.blob.core.windows.net/legalterms/3E5ED_legalterms_DDN%253a2DWHAMCLOUD%253a2D5345716%253a24EXASCALER%253a5FCLOUD%253a24EXASCALER%253a5FCLOUD%253a5F523%253a5FREDHAT%253a24RI46C54X4ZEJTZXVGNKQTMOOLKIMCBELLB75XRKMA6KZU63OEITXAF4VOL2MD4M4BTNGHGCYM4NAH2P7REASLOTOHK72WYRNBCHH5WI.txt",
  "name": "exascaler_cloud_523_redhat",
  "plan": "exascaler_cloud_523_redhat",
  "privacyPolicyLink": "https://www.ddn.com/privacy-policy/",
  "product": "exascaler_cloud",
  "publisher": "ddn-whamcloud-5345716",
  "retrieveDatetime": "2021-08-19T17:35:47.7331799Z",
  "signature": "O54TTPAEGUYG5CWP67PDJS2SAVFL5IQ4LLH5K3UC7YIWZJFQPTLLPAUIRA3EKFF7B4XKMPMA42AD6MQJY7HZOGJH42KTZXLJD6ZVPPA",
  "type": "Microsoft.MarketplaceOrdering/offertypes"
}
```
* For EXAScaler Cloud CentOS Linux based image:
```
$ az vm image terms accept --urn ddn-whamcloud-5345716:exascaler_cloud:exascaler_cloud_523_centos:5.2.3
{
  "accepted": true,
  "id": "/subscriptions/9978cd1b-936a-4296-8061-67c9d963dd40/providers/Microsoft.MarketplaceOrdering/offerTypes/Microsoft.MarketplaceOrdering/offertypes/publishers/ddn-whamcloud-5345716/offers/exascaler_cloud/plans/exascaler_cloud_523_centos/agreements/current",
  "licenseTextLink": "https://mpcprodsa.blob.core.windows.net/legalterms/3E5ED_legalterms_DDN%253a2DWHAMCLOUD%253a2D5345716%253a24EXASCALER%253a5FCLOUD%253a24EXASCALER%253a5FCLOUD%253a5F523%253a5FCENTOS%253a24RI46C54X4ZEJTZXVGNKQTMOOLKIMCBELLB75XRKMA6KZU63OEITXAF4VOL2MD4M4BTNGHGCYM4NAH2P7REASLOTOHK72WYRNBCHH5WI.txt",
  "name": "exascaler_cloud_523_centos",
  "plan": "exascaler_cloud_523_centos",
  "privacyPolicyLink": "https://www.ddn.com/privacy-policy/",
  "product": "exascaler_cloud",
  "publisher": "ddn-whamcloud-5345716",
  "retrieveDatetime": "2021-08-19T17:36:36.3180347Z",
  "signature": "H7GVHMXUGV73GL6IUBQRD5HQANNDX5343KRPHWTCMZAEPMJF6RFXDO3PT6CF5QK5HRCJH5MQLG7MWIAWQILX5DQL4UAO5ENPJCRVRWA",
  "type": "Microsoft.MarketplaceOrdering/offertypes"
}
```
[Learn more about the image terms](https://mpcprodsa.blob.core.windows.net/legalterms/3E5ED_legalterms_DDN%253a2DWHAMCLOUD%253a2D5345716%253a24EXASCALER%253a5FCLOUD%253a24EXASCALER%253a5F520%253a24RI46C54X4ZEJTZXVGNKQTMOOLKIMCBELLB75XRKMA6KZU63OEITXAF4VOL2MD4M4BTNGHGCYM4NAH2P7REASLOTOHK72WYRNBCHH5WI.txt)

## Steps to configure Terraform

Download Terraform [scripts](https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/2.0.1.tar.gz) and extract the [tarball](https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/2.0.1.tar.gz):
```
$ curl -sL https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/2.0.1.tar.gz | tar xz
```

Change Terraform variables according you requirements:
```
$ cd exascaler-cloud-terraform-scripts-2.0.1/az
$ vi terraform.tfvars
```

### List of available variables

#### Common options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `profile`| `custom`      | Configuration profile name: small, medium or custom. The configuration profile name will be displayed in the Azure dashboard. |
| `fsname` | `exacloud` | EXAScaler filesystem name        |
| `subscription` | `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX` | Subscription ID - please use ID of you active Azure subscription. [Learn more](https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade) |
| `location` | `West US` | Azure region to manage resources. [Learn more](https://azure.microsoft.com/global-infrastructure/geographies) |

#### Availability options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `availability.type` | `none` | Availability type: `none` - no infrastructure redundancy required, `set` - to create an availability set and automatically distribute resources across multiple fault domains, `zone` - to physically separate resources within an Azure region. [Learn more](https://docs.microsoft.com/azure/virtual-machines/availability) |
| `availability.zone` | `1` | Availability zone - unique physical locations within a Azure region. Use `1`, `2` or `3` to explicitly specify the availability zone. [Learn more](https://docs.microsoft.com/azure/availability-zones) |

#### Resource group options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `resource_group.new` | `true` | Create a new resource group, or use an existing one: `true` or `false` |
|`resource_group.name` | `existing-resource-group` | Existing resource group name, will be using if `new` is `false` |

[Learn more](https://docs.microsoft.com/azure/azure-resource-manager/management/manage-resource-groups-portal)

#### Proximity placement group options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `proximity_placement_group.new` | `true` | Create a new proximity placement group, or use an existing one: `true` or `false`|
| `proximity_placement_group.name` | `existing-proximity-placement-group` | Existing proximity placement group name, will be using if new is false |

[Learn more](https://azure.microsoft.com/blog/introducing-proximity-placement-groups) 

#### Network options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `network.new` | `true` | Create a new network, or use an existing one: `true` or `false` |
| `network.name` | `existing-network` | Existing network name, will be using only if `new` option is `false` |
| `network.address` | `10.0.0.0/8` | IP address in CIDR notation for the new virtual network |

[Learn more](https://docs.microsoft.com/azure/virtual-network/virtual-networks-overview)

#### Subnet options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `subnet.new` | `true` | Create a new subnet, or use an existing one: `true` or `false` |
| `subnet.name` | `existing-subnet` | Existing subnet name, will be using only if `new` option is `false` |
| `network.address` | `10.0.0.0/24` | IP address in CIDR notation for the new subnet |

[Learn more](https://docs.microsoft.com/azure/virtual-network/virtual-networks-overview)

#### Authentication options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `admin.username` | `stack` | User name for remote SSH access |
| `admin.ssh_public_key` | `~/.ssh/id_rsa.pub` | Path to the local SSH public key. This file will be added to admin home directory as `.ssh/authorized_keys` |

[Learn more](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed)

#### SSH options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `ssh.enable` | `true` | `true` or `false`: enable/disable remote SSH access |
| `ssh.source` | `0.0.0.0/0` | Source IP address in CIDR notation for remote SSH access |

#### HTTP options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `http.enable` | `true` | `true` or `false`: enable/disable remote HTTP access |
| `http.source` | `0.0.0.0/0` | Source address in CIDR notation IP for remote HTTP access |

[Learn more](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)

#### Boot disk options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `boot.disk_type` | `StandardSSD_LRS` | Specifies the type of managed disk to create: `Standard_LRS`, `Premium_LRS` or `StandardSSD_LRS` |
| `boot.disk_cache` | `ReadWrite` | Specifies the caching requirements for the target disk: `None`, `ReadOnly` or `ReadWrite` |
| `boot.auto_delete` | `true` | Delete the boot disk automatically when deleting the virtual machine: `true` or `false` |
| `boot.disk_size` | `64` | Boot disk size in GB |

[Learn more](https://docs.microsoft.com/azure/virtual-machines/disks-types)

#### Source image options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `image.publisher` | `ddn-whamcloud-5345716` | Specifies the publisher of the image used to create the virtual machine |
| `image.offer` | `exascaler_cloud` | Specifies the offer of the image used to create the virtual machine |
| `image.sku` | `exascaler_cloud_523_centos` | Specifies the SKU of the image used to create the virtual machine. CentOS based image - `exascaler_cloud_523_centos`, Red Hat Enterprise Linux based image - `exascaler_cloud_523_redhat`  |
| `image.version` | `5.2.3` | Specifies the version of the image used to create the virtual machine |
| `image.accept`  | `false` | Allows automatically accepting the legal terms for a Marketplace image |

[Learn more](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/imaging)

#### Storage account options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `storage_account.kind` | `StorageV2` | Defines the kind of account. Valid options are `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage` and `StorageV2` |
| `storage_account.tier` | `Standard` | Defines the tier to use for this storage account. Valid options are `Standard` and `Premium` |
| `storage_account.replication` | `LRS` | Defines the type of replication to use for this storage account. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS` |

[Learn more](https://docs.microsoft.com/azure/storage/common/storage-account-overview)

#### Virtual machines options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `{mgs,mds,oss,cls}.node_type` | `Standard_D1_v2` | The type of virtual machine. [Learn more](https://docs.microsoft.com/azure/cloud-services/cloud-services-sizes-specs) |
| `{mgs,mds,oss,cls}.node_count` | `1`   | The number of virtual machines (`1` for `mgs` and `mds` instances) |
| `{mgs,mds,oss,cls}.public_ip` | `true` for `mgs`, `false` for `mds`, `oss` and `cls` | Assign an external IP address: `true` or `false` |
| `accelerated_network` | `false` | Enable accelerated networking. [Learn more](https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli) |

#### Target disks options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `{mgt,mnt,mdt,ost,clt}.disk_type` | `Standard_LRS` | Specifies the type of managed disk to create: `Standard_LRS`, `StandardSSD_LRS`, `Premium_LRS` |
| `{mgt,mnt,mdt,ost,clt}.disk_cache` | `None` | Specifies the caching requirements for the target disk: `None`, `ReadOnly` or `ReadWrite` |
| `{mgt,mnt,mdt,ost,clt}.disk_size` | `512` | Target disk size in GB |
| `{mgt,mnt,mdt,ost,clt}.disk_count` | `1`   | Number of target disks: `1-32` (`1` for `mgt` and `mnt`) |
| `{mdt,ost}.disk_raid` | `false` | Enable/disable RAID0 striped volume for MDT/OST targets |

[Learn more](https://docs.microsoft.com/azure/virtual-machines/disks-types)

Initialize a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control. It is safe to run this command multiple times:
```
$ terraform init
```

Validate configuration options:
```
$ terraform validate
```

## Steps to deploy an EXAScaler Cloud environment

Review an execution plan:
```
$ terraform plan
```

Apply the changes required to reach the desired state of the configuration:
```
$ terraform apply
...
  Enter a value: yes
...
Apply complete! Resources: 103 added, 0 changed, 0 destroyed.

Outputs:

azure_dashboard = "https://portal.azure.com/#@753b6e26-6fd3-43e6-8248-3f1735d59bb4/dashboard/arm/subscriptions/9978cd1b-936a-4296-8061-67c9d963dd40/resourceGroups/exascaler-cloud-b59f-resource-group/providers/Microsoft.Portal/dashboards/exascaler-cloud-b59f-dashboard"

http_console = "http://exascaler-cloud-b59f-mgs0.westus.cloudapp.azure.com"

mount_command = "mount -t lustre 10.0.0.13@tcp:/exacloud /mnt/exacloud"

private_addresses = {
  "exascaler-cloud-b59f-cls0" = "10.0.0.9"
  "exascaler-cloud-b59f-cls1" = "10.0.0.12"
  "exascaler-cloud-b59f-cls2" = "10.0.0.11"
  "exascaler-cloud-b59f-cls3" = "10.0.0.7"
  "exascaler-cloud-b59f-mds0" = "10.0.0.5"
  "exascaler-cloud-b59f-mgs0" = "10.0.0.13"
  "exascaler-cloud-b59f-oss0" = "10.0.0.8"
  "exascaler-cloud-b59f-oss1" = "10.0.0.4"
  "exascaler-cloud-b59f-oss2" = "10.0.0.6"
  "exascaler-cloud-b59f-oss3" = "10.0.0.10"
}

ssh_console = {
  "exascaler-cloud-b59f-mgs0" = "ssh -A stack@exascaler-cloud-b59f-mgs0.westus.cloudapp.azure.com"
}
```

## Steps to access the EXAScaler Cloud environment

Now you can access the EXAScaler Cloud environment:
```
$ eval $(ssh-agent)
Agent pid 18111
 
$ ssh-add
Identity added: /home/user/.ssh/id_rsa
 
$ ssh -A stack@exascaler-cloud-b59f-mgs0.westus.cloudapp.azure.com
 
[stack@exascaler-cloud-b59f-mgs0 ~]$ df -h -t lustre
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdd        124G  2.4M  118G   1% /mnt/targets/MGS

[stack@exascaler-cloud-b59f-mgs0 ~]$ loci hosts
10.0.0.9	exascaler-cloud-b59f-cls0
10.0.0.12	exascaler-cloud-b59f-cls1
10.0.0.11	exascaler-cloud-b59f-cls2
10.0.0.7	exascaler-cloud-b59f-cls3
10.0.0.5	exascaler-cloud-b59f-mds0
10.0.0.13	exascaler-cloud-b59f-mgs0
10.0.0.8	exascaler-cloud-b59f-oss0
10.0.0.4	exascaler-cloud-b59f-oss1
10.0.0.6	exascaler-cloud-b59f-oss2
10.0.0.10	exascaler-cloud-b59f-oss3

[stack@exascaler-cloud-b59f-mgs0 ~]$ ssh exascaler-cloud-b59f-cls0
[stack@exascaler-cloud-b59f-cls0 ~]$ lfs df
UUID                   1K-blocks        Used   Available Use% Mounted on
exacloud-MDT0000_UUID   315302464        6212   309927544   1% /mnt/exacloud[MDT:0]
exacloud-OST0000_UUID   529449792        1252   524063448   1% /mnt/exacloud[OST:0]
exacloud-OST0001_UUID   529449792        1256   524063444   1% /mnt/exacloud[OST:1]
exacloud-OST0002_UUID   529449792        1260   524063440   1% /mnt/exacloud[OST:2]
exacloud-OST0003_UUID   529449792        1264   524063436   1% /mnt/exacloud[OST:3]
exacloud-OST0004_UUID   529449792        1268   524063432   1% /mnt/exacloud[OST:4]
exacloud-OST0005_UUID   529449792        1272   524063428   1% /mnt/exacloud[OST:5]
exacloud-OST0006_UUID   529449792        1256   524063444   1% /mnt/exacloud[OST:6]
exacloud-OST0007_UUID   529449792        1260   524063440   1% /mnt/exacloud[OST:7]
exacloud-OST0008_UUID   529449792        1260   524063440   1% /mnt/exacloud[OST:8]
exacloud-OST0009_UUID   529449792        1264   524063436   1% /mnt/exacloud[OST:9]
exacloud-OST000a_UUID   529449792        1272   524063428   1% /mnt/exacloud[OST:10]
exacloud-OST000b_UUID   529449792        1272   524063428   1% /mnt/exacloud[OST:11]
exacloud-OST000c_UUID   529449792        1256   524063444   1% /mnt/exacloud[OST:12]
exacloud-OST000d_UUID   529449792        1260   524063440   1% /mnt/exacloud[OST:13]
exacloud-OST000e_UUID   529449792        1264   524063436   1% /mnt/exacloud[OST:14]
exacloud-OST000f_UUID   529449792        1268   524063432   1% /mnt/exacloud[OST:15]
exacloud-OST0010_UUID   529449792        1272   524063428   1% /mnt/exacloud[OST:16]
exacloud-OST0011_UUID   529449792        1272   524063428   1% /mnt/exacloud[OST:17]
exacloud-OST0012_UUID   529449792        1260   524063440   1% /mnt/exacloud[OST:18]
exacloud-OST0013_UUID   529449792        1260   524063440   1% /mnt/exacloud[OST:19]
exacloud-OST0014_UUID   529449792        1264   524063436   1% /mnt/exacloud[OST:20]
exacloud-OST0015_UUID   529449792        1268   524063432   1% /mnt/exacloud[OST:21]
exacloud-OST0016_UUID   529449792        1272   524063428   1% /mnt/exacloud[OST:22]
exacloud-OST0017_UUID   529449792        1276   524063424   1% /mnt/exacloud[OST:23]

filesystem_summary:  12706795008       30348 12577522452   1% /mnt/exacloud
```

## Steps to add storage capacity in an existing EXAScaler Cloud environment

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

## Steps to upgrade an existing EXAScaler Cloud environment

A software upgrade for an existing EXAScaler Cloud environment is possible by recreating the running VM instances using a new version of the OS image. And it requires some manual steps.

Create a backup copy for the existing Terraform directory (\*.tf, terraform.tfvars and terraform.tfstate files):
```
$ cd /path/to/exascaler-cloud-terraform-scripts-x.y.z/az
$ tar pcfz backup.tgz *.tf terraform.tfvars terraform.tfstate
```

Update Terraform scripts using the latest available EXAScaler Cloud Terraform [scripts](https://github.com/DDNStorage/exascaler-cloud-terraform):
```
$ cd /path/to
$ curl -sL https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/2.0.1.tar.gz | tar xz
$ cd exascaler-cloud-terraform-scripts-2.0.1/az
```

Copy the terraform.tfstate file from the existing Terraform directory:
```
$ cp -iv /path/to/exascaler-cloud-terraform-scripts-x.y.z/az/terraform.tfstate .
```

Review and update the terraform.tfvars file using configuration options for the existing environment:
```
$ diff -u  /path/to/exascaler-cloud-terraform-scripts-x.y.z/az/terraform.tfvars terraform.tfvars
$ vi terraform.tfvars
```

Review the execution plan to make sure all changes are expected:
```
$ terraform plan
```

Unmount the existing EXAScaler Cloud filesystem using the provided [esc-ctl](https://github.com/DDNStorage/exascaler-cloud-terraform/az/scripts/esc-ctl) script. This step is required to ensure data consistency during the upgrade:
```
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
```
$ terraform destroy
...
  Enter a value: yes
...
Destroy complete! Resources: 103 destroyed.
```
