#!/bin/bash

set -e -o pipefail

target="${1}"
if [ x"${2}" == x ]; then
	packer=packerio
else
	packer="${2}"
fi

# Need to fetch the latest version of the rawhide stack
if [[ "${target}" =~ "rawhide" ]]; then
	python -m pip install -r requirements.txt
	./utils/get_rawhide.py -f "${target}"
fi

# Don't talk back to Hashicorp
export CHECKPOINT_DISABLE=1
export VAGRANT_CHECKPOINT_DISABLE=1

sudo df -h
timestamp="$(date +%Y%m%d)"
# Perform actual build
sudo -E PACKER_LOG=1 "${packer}" build -only=qemu -parallel=false \
	-var 'headless=true' -var "version=${timestamp}" -var "disk_size=10000" \
	"${target}"
