#!/bin/bash

set -e -x -o pipefail

distro="${1}"
version="${2}"
arch="${3}"
if [ x"${4}" == x ]; then
	packer=packerio
else
	packer="${4}"
fi

# Need to fetch the latest version of the ISO file
python -m pip install -r requirements.txt
./utils/get_image.py -f "${target}" -v "${version}" -a "${arch}"

# Don't talk back to Hashicorp
export CHECKPOINT_DISABLE=1
export VAGRANT_CHECKPOINT_DISABLE=1

target="${distro}-${version}-${arch}.json"
# Perform actual build
sudo -E "${packer}" build -only=qemu -parallel=false \
	-var 'headless=true' -var "disk_size=10000" \
	-var "ssh_timeout=240m" "${target}"
