#!/bin/bash

set -e -o pipefile

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

# Perform actual build
"${packer}" build -only=qemu -parallel=false "${target}"
