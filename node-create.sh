set -xe

IPMI_ADDR=10.10.1.1
IPMI_PORT=6230
IMAGE_URL=http://tarballs.openstack.org/ironic-python-agent/coreos/files/coreos_production_pxe_image-oem-stable-queens.cpio.gz
KERNEL_URL=http://tarballs.openstack.org/ironic-python-agent/coreos/files/coreos_production_pxe-stable-queens.vmlinuz
INSTANCE_IMAGE=https://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img
INSTANCE_KERNEL=https://download.cirros-cloud.net/0.4.0/cirros-0.4.0-aarch64-kernel
INSTANCE_RAMDISK=https://download.cirros-cloud.net/0.4.0/cirros-0.4.0-aarch64-initramfs
MAC=00:10:04:33:55:04
KERNEL=vmlin
NAME="node-4"

os="venv/bin/openstack baremetal"

# 00:10:04:33:55:04

$os node maintenance set $NAME | true
$os node delete $NAME | true

$os node create --name $NAME \
    --driver ipmi \
    --driver-info ipmi_address=$IPMI_ADDR \
    --driver-info ipmi_port=$IPMI_PORT \
    --driver-info ipmi_username=admin \
    --driver-info ipmi_password=password \
    --driver-info deploy_kernel=$KERNEL_URL \
    --driver-info deploy_ramdisk=$IMAGE_URL \
    --driver-info ipmi_terminal_port=$IPMI_PORT \
    --os-baremetal-api-version=1.31 \
    --deploy-interface direct \

UUID=$($os node show $NAME | grep " uuid " | awk '{ print $4}')

$os node set $UUID \
    --instance-info root_gb=16 \
    --instance-info image_source=$INSTANCE_IMAGE \
    --instance-info image_checksum=443b7623e27ecf03dc9e01ee93f67afe \
    --network-interface noop \
    --deploy-interface direct \
    --os-baremetal-api-version=1.31 \

$os port create --node $UUID $MAC

$os node validate $UUID

#$os node maintenance set node-4
#$os node abort node-4
