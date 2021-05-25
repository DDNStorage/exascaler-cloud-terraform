# EXAScaler Cloud Terraform scripts for Microsoft Azure

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

## Steps to accept the terms of use for DDN EXAScaler Cloud image

To deploy DDN EXAScaler Cloud, you need to accept the terms:
```
$ az vm image terms accept --urn ddn-whamcloud-5345716:exascaler_cloud:exascaler_520:5.2.0
{
  "accepted": true,
  "id": "/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/providers/Microsoft.MarketplaceOrdering/offerTypes/Microsoft.MarketplaceOrdering/offertypes/publishers/ddn-whamcloud-5345716/offers/exascaler_cloud/plans/exascaler_520/agreements/current",
  "licenseTextLink": "https://mpcprodsa.blob.core.windows.net/legalterms/3E5ED_legalterms_DDN%253a2DWHAMCLOUD%253a2D5345716%253a24EXASCALER%253a5FCLOUD%253a24EXASCALER%253a5F520%253a24RI46C54X4ZEJTZXVGNKQTMOOLKIMCBELLB75XRKMA6KZU63OEITXAF4VOL2MD4M4BTNGHGCYM4NAH2P7REASLOTOHK72WYRNBCHH5WI.txt",
  "name": "exascaler_520",
  "plan": "exascaler_520",
  "privacyPolicyLink": "https://www.ddn.com/privacy-policy/",
  "product": "exascaler_cloud",
  "publisher": "ddn-whamcloud-5345716",
  "retrieveDatetime": "2021-05-25T21:52:25.6605447Z",
  "signature": "signature",
  "type": "Microsoft.MarketplaceOrdering/offertypes"
}
```
[Learn more about the image terms](https://mpcprodsa.blob.core.windows.net/legalterms/3E5ED_legalterms_DDN%253a2DWHAMCLOUD%253a2D5345716%253a24EXASCALER%253a5FCLOUD%253a24EXASCALER%253a5F520%253a24RI46C54X4ZEJTZXVGNKQTMOOLKIMCBELLB75XRKMA6KZU63OEITXAF4VOL2MD4M4BTNGHGCYM4NAH2P7REASLOTOHK72WYRNBCHH5WI.txt)

## Steps to configure Terraform

Download Terraform [scripts](https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/2.0.0.zip) and extract tarball:
```
$ curl -sL https://github.com/DDNStorage/exascaler-cloud-terraform/archive/refs/tags/scripts/2.0.0.tar.gz | tar xz
```

Change Terraform variables according you requirements:
```
$ cd exascaler-cloud-terraform-scripts-2.0.0/az
$ vi terraform.tfvars
```

### List of available variables

#### Common options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `fsname` | `exacloud` | EXAScaler filesystem name        |
| `subscription` | `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX` | Subscription ID - please use ID of you active Azure subscription. [Learn more](https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade) |
| `location` | `West US` | Azure region to manage resources. [Learn more](https://azure.microsoft.com/global-infrastructure/geographies) |
| `zone` | `0` | Availability zone - unique physical locations within a Azure region. Use 1, 2, 3 to explicitly specify the availability zone or  0 to auto select the availability zone. [Learn more](https://docs.microsoft.com/azure/availability-zones) |

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
| `network.address` | `10.0.0.0/8` | Valid CIDR range of the form x.x.x.x/x for the new virtual network |

[Learn more](https://docs.microsoft.com/azure/virtual-network/virtual-networks-overview)

#### Subnet options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `subnet.new` | `true` | Create a new subnet, or use an existing one: `true` or `false` |
| `subnet.name` | `existing-subnet` | Existing subnet name, will be using only if `new` option is `false` |
| `network.address` | `10.0.0.0/24` | Valid CIDR range of the form x.x.x.x/x for the new subnet |

[Learn more](https://docs.microsoft.com/azure/virtual-network/virtual-networks-overview)

#### Authentication options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `admin.username` | `stack` | User name for remote SSH access |
| `admin.ssh_public_key` | `~/.ssh/id_rsa.pub` | Path to the local SSH public key. This file will be added to admin home directory as `.ssh/authorized_keys` |

[Learn more](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed)

#### Security options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `security.enable_ssh` | `true` | `true` or `false`: enable/disable remote SSH access |
| `security.ssh_source_range` | `0.0.0.0/0` | Source IP for remote SSH access |
| `security.enable_http` | `true` | `true` or `false`: enable/disable remote HTTP console |
| `security.http_source_range` | `0.0.0.0/0` | Source IP for remote HTTP access |

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
| `image.sku` | `exascaler_520` | Specifies the SKU of the image used to create the virtual machine |
| `image.version` | `5.2.0` | Specifies the version of the image used to create the virtual machine |

[Learn more](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/imaging)

#### Storage account options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `storage_account.kind` | `StorageV2` | Defines the kind of account. Valid options are `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage` and `StorageV2` |
| `storage_account.tier` | `Standard` | Defines the tier to use for this storage account. Valid options are `Standard` and `Premium` |
| `storage_account.replication` | `GRS` | Defines the type of replication to use for this storage account. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS` |

[Learn more](https://docs.microsoft.com/azure/storage/common/storage-account-overview)

#### Virtual machines options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `{mgs,mds,oss,cls}.node_type` | `Standard_D1_v2` | The type of virtual machine. [Learn more](https://docs.microsoft.com/azure/cloud-services/cloud-services-sizes-specs) |
| `{mgs,mds,oss,cls}.node_count` | `1`   | The number of virtual machines (`1` for `mgs` and `mds` instances) |
| `{mgs,mds,oss,cls}.public_ip` | `true` (`mgs`), `false` (`mds`, `oss`, `cls`) | Assign an external IP address: `true` or `false` |
| `accelerated_network` | `false` | Enable accelerated networking. [Learn more](https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli) |

#### Target disks options
| Variable | Default Value | Description |
| -------- | ------------- | ----------- |
| `{mgt,mnt,mdt,ost,clt}.disk_type` | `Standard_LRS` | Specifies the type of managed disk to create: `Standard_LRS`, `StandardSSD_LRS`, `Premium_LRS` |
| `{mgt,mnt,mdt,ost,clt}.disk_cache` | `None` | Specifies the caching requirements for the target disk: `None`, `ReadOnly` or `ReadWrite` |
| `{mgt,mnt,mdt,ost,clt}.disk_size` | `512` | Target disk size in GB |
| `{mgt,mnt,mdt,ost,clt}.disk_count` | `1`   | Number of target disks: `1-128` (`1` for `mgt` and `mnt`) |

[Learn more](https://docs.microsoft.com/azure/virtual-machines/disks-types)

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
Apply complete! Resources: 37 added, 0 changed, 0 destroyed.

Outputs:

mount_command = "mount -t lustre 10.0.0.7@tcp:/exacloud /mnt/exacloud"

private_addresses = {
  "exascaler-cloud-13bd-cls0" = "10.0.0.6"
  "exascaler-cloud-13bd-mds0" = "10.0.0.5"
  "exascaler-cloud-13bd-mgs0" = "10.0.0.7"
  "exascaler-cloud-13bd-oss0" = "10.0.0.4"
}

ssh_console = {
  "exascaler-cloud-13bd-mgs0" = "ssh -A stack@exascaler-cloud-13bd-mgs0.westus.cloudapp.azure.com"
}

web_console = "http://exascaler-cloud-13bd-mgs0.westus.cloudapp.azure.com"
```

Now you can access the EXAScaler Cloud environment:
```
$ eval $(ssh-agent)
Agent pid 18111
 
$ ssh-add
Identity added: /home/user/.ssh/id_rsa
 
$ ssh -A stack@exascaler-cloud-13bd-mgs0.westus.cloudapp.azure.com
 
[stack@exascaler-cloud-13bd-mgs0 ~]$ df -h -t lustre
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdc        249G  2.1M  237G   1% /mnt/targets/MGS
 
[stack@exascaler-cloud-13bd-mgs0 ~]$ ssh 10.0.0.4

[stack@exascaler-cloud-13bd-oss0 ~]$ df -h -t lustre
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdc        252G  1.3M  239G   1% /mnt/targets/exacloud-OST0000
```

Destroy the EXAScaler Cloud environment:
```
$ terraform destroy
...
 
  Enter a value: yes
 
...
 
Destroy complete! Resources: 37 destroyed.
```

