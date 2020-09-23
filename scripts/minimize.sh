#!/bin/sh

set -e
set -x

rm -rf /home/vagrant/.ansible
sudo rm -rf /root/.ansible

#if [[ "${PACKER_BUILD_NAME}" != *"silverblue"* ]]; then
	sudo dd if=/dev/zero of=/var/EMPTY bs=1M || :
	sync
	sudo rm /var/EMPTY
	sync
#fi

# In CentOS 7, blkid returns duplicate devices
swap_device_uuid=`sudo /sbin/blkid -t TYPE=swap -o value -s UUID | uniq`
swap_device_label=`sudo /sbin/blkid -t TYPE=swap -o value -s LABEL | uniq`
if [ -n "$swap_device_uuid" ]; then
  swap_device=`readlink -f /dev/disk/by-uuid/"$swap_device_uuid"`
elif [ -n "$swap_device_label" ]; then
  swap_device=`readlink -f /dev/disk/by-label/"$swap_device_label"`
fi

if [ ! -z "${swap_device}" -a -e "${swap_device}" ]; then
	sudo /sbin/swapoff "$swap_device"
	sudo dd if=/dev/zero of="$swap_device" bs=1M || :
	sudo /sbin/mkswap ${swap_device_label:+-L "$swap_device_label"} ${swap_device_uuid:+-U "$swap_device_uuid"} "$swap_device"
fi
