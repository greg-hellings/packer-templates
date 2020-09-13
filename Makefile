SHELL := /bin/bash
BOXEN := $(addsuffix .box, fedora-30-x86_64-qemu \
	fedora-31-x86_64-qemu fedora-31-ppc64le-qemu \
	fedora-32-x86_64-qemu fedora-32-ppc64le-qemu \
	fedora-rawhide-x86_64-qemu)
PPC_BOXEN := $(addsuffix .box, \
	fedora-rawhide-ppc64le-qemu, \
	fedora-31-ppc64le-qemu, \
	fedora-32-ppc64le-qemu, \
	fedora-33-ppc64le-qemu \
)
ANSIBLE := $(wildcard ansible/**/*.yml)
CONFIGS := $(wildcard config/*)
BUILT_BOXES = $(wildcard *.box)
# Build headless on the GitHub agents
HEADLESS = $(shell if [ -z "$${GITHUB_REF}" ]; then printf "false"; else printf "true"; fi)

##################
#
## First, how to build boxes
#
##################
all: $(BOXEN)
	@echo ''

ppc: $(PPC_BOXEN)
	@echo ''

fedora-rawhide-x86_64-qemu.box: boxen.json config.iso rawhide.json rawhide.iso
	PACKER_LOG=1 packerio build -parallel-builds=1 -var-file=rawhide.json -var headless=$(HEADLESS) -only=$(basename $@) $<

fedora-rawhide-ppc64le-qemu.box: boxen.json config.iso rawhide_ppc.json rawhide_ppc.iso
	./utils/extend_grub_timeout.sh "$@"
	PACKER_LOG=1 packerio build -parallel-builds=1 -var-file=rawhide_ppc.json -var headless=$(HEADLESS) -only=$(basename $@) $<

fedora-f33-x86_64-qemu.box: boxen.json config.iso f33.json f33.iso
	PACKER_LOG=1 packerio build -parallel-builds=1 -var-file=f33.json -var headless=$(HEADLESS) -only=$(basename $@) $<

fedora-f33-ppc64le-qemu.box: boxen.json config.iso f33-ppc64le.json f33-ppc64le.iso
	PACKER_LOG=1 packerio build -parallel-builds=1 -var-file=f33_ppc.json -var headless=$(HEADLESS) -only=$(basename $@) $<

%.box: boxen.json config.iso
	./utils/extend_grub_timeout.sh "$@"
	packerio build -parallel-builds=1 -var headless=$(HEADLESS) -only=$(basename $@) $<

import:
	$(foreach box,$(BUILT_BOXES),$(shell vagrant box add $(basename $(box)) ./$(box)))

##################
#
## Dependencies we need to do builds
#
##################
config.iso:
	$(MAKE) -C http/cloud-init

venv/bin/python: requirements.txt
	python3 -m virtualenv --python=python3 venv
	venv/bin/python -m pip install -U pip
	venv/bin/pip install -r requirements.txt

boxen.json: boxen.yml venv/bin/python
	venv/bin/python convert.py boxen.yml boxen.json

###################
#
## Things for images that change often
#
###################
f33-ppc64le.iso f33-ppc64le.json:
	./utils/get_fedora_images.sh f33-ppc64le

f33.iso f33.json:
	./utils/get_fedora_images.sh f33

rawhide.iso rawhide.json:
	./utils/get_fedora_images.sh rawhide

rawhide_ppc.iso rawhide_ppc.json:
	./utils/get_fedora_images.sh rawhide-ppc64le

clean:
	rm -f *.json *.iso *.box *.qcow2 build.* http/cloud-init/config.iso
	rm -rf output-* venv
	sudo umount mnt || true
	rmdir mnt || true
	chmod -R +w new_mnt || true
	rm -rf new_mnt

.PHONY: config.iso all clean import
