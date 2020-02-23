#!/bin/bash

set -e -x -o pipefail

target="${1}"
if [ x"${2}" == x ]; then
	packer=packerio
else
	packer="${2}"
fi

# Need to fetch the latest version of the ISO file
python -m pip install -r requirements.txt
./utils/get_image.py -f "${target}"

# Don't talk back to Hashicorp
export CHECKPOINT_DISABLE=1
export VAGRANT_CHECKPOINT_DISABLE=1

# Debugging info
sudo df -h
sudo du -sh /* || :
sudo du -sh /usr/* || :
timestamp="$(date +%Y%m%d)"
# Perform actual build
sudo -E "${packer}" build -only=qemu -parallel=false \
	-var 'headless=true' -var "version=${timestamp}" -var "disk_size=10000" \
	-var "ssh_timeout=240m" "${target}"
