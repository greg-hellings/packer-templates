#!/bin/bash
set -ex -o pipefail

name="${1}"
if [[ "${name}" == *ppc64le-*.box ]]; then
	target="$(basename -s .box "${name}")"
	box=$(jq -r ".builders[] | select(.name == \"${target}\") | .iso_url" boxen.json)
	# The files get coppied as read only by default
	mnt=$(mktemp -d)
	new_mnt=$(mktemp -d)
	sudo mount -t iso9660 -o loop "${box}" "${mnt}"
	cp -r "${mnt}/"* "${mnt}/.discinfo" "${new_mnt}"
	chmod +w "${new_mnt}/boot/grub/grub.cfg"
	chmod +w "${new_mnt}/boot/grub/"
	sed -i -e 's/set timeout=5/set timeout=60/' "${new_mnt}/boot/grub/grub.cfg"
	chmod -w "${new_mnt}/boot/grub/grub.cfg"
	chmod -w "${new_mnt}/boot/grub/"
	sudo umount "${mnt}"
	mkisofs -r -iso-level 4 -chrp-boot -o "${box}" "${new_mnt}"
	./utils/update_sha.sh "${box}"
	chmod -R +w "${new_mnt}"
	rm -rf "${new_mnt}" "${mnt}"
fi
