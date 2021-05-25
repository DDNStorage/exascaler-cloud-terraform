#!/usr/bin/env bash

cat >>/etc/loci.conf <<EOF
key_dir: ~/.ssh
HaEnabled: True
EnableIPSec: False
EnableMdtRaid0: False
EnableOstRaid0: False
LustreAZ: ${zone}
FsName: ${fsname}
FilesystemCapacity: ${capacity}
ConfigurationProfile: ${profile}
Deployment: ${deployment}
MgtVolumeSize: ${mgt_disk_size}
MgtVolumeType: ${mgt_disk_type}
MgtVolumePiops: 0
GangliaVolumeSize: ${mnt_disk_size}
GangliaVolumeType: ${mnt_disk_type}
GangliaVolumePiops: 0
MdsCount: ${mds_node_count}
MdtVolumeSize: ${mdt_disk_size}
MdtVolumeType: ${mdt_disk_type}
MdtVolumeCount: ${mdt_disk_count}
MdtVolumePiops: 0
OssCount: ${oss_node_count}
OstVolumeSize: ${ost_disk_size}
OstVolumeType: ${ost_disk_type}
OstVolumeCount: ${ost_disk_count}
OstVolumePiops: 0
RolesTable: ${deployment}-role-config
FilesystemTable: ${deployment}-fs-config
EOF

loci init
