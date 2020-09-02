#!/bin/bash
set -ex -o pipefail

name="${1}"
if [[ "${name}" == *ppc64le-*.box ]]; then
	if [[ "${name}" != *rawhide* ]]; then
		url=$(jq -r ".builders[] | select(.name == \"$(basename -s .box "${name}")\") | .iso_url" boxen.json)
		dest="$(basename "${url}")"
		curl -O "${url}" -C -
	else
		dest=$(jq -r .rawhide_ppc_url rawhide_ppc_sha.json)
	fi
	sudo umount mnt || true
	rmdir mnt || true
	# The files get coppied as read only by default
	chmod -R +w new_mnt || true
	rm -rf new_mnt
	mkdir -p mnt
	mkdir -p new_mnt
	sudo mount -t iso9660 -o loop "${dest}" mnt
	cp -r mnt/* mnt/.discinfo new_mnt
	chmod +w new_mnt/boot/grub/grub.cfg
	chmod +w new_mnt/boot/grub/
	sed -i -e 's/set timeout=5/set timeout=60/' new_mnt/boot/grub/grub.cfg
	chmod -w new_mnt/boot/grub/grub.cfg
	chmod -w new_mnt/boot/grub/
	sudo umount mnt
	mkisofs -r -iso-level 4 -chrp-boot -o "${dest}" new_mnt
	./update_sha.py "$(basename -s .box "${name}")" "$(sha256sum "${dest}" | sed -E -e 's/ .*$//')"
fi
