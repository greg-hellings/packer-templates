SHELL := /bin/bash
BOXEN := $(addsuffix .box, fedora-30-x86_64-qemu \
	fedora-31-x86_64-qemu fedora-31-ppc64le-qemu \
	fedora-32-x86_64-qemu fedora-32-ppc64le-qemu \
	fedora-rawhide-x86_64-qemu \
	centos-6-x86_64-qemu, \
	centos-7-x86_64-qemu)
PPC_BOXEN := $(addsuffix .box, \
	fedora-rawhide-ppc64le-qemu, \
	fedora-32-ppc64le-qemu, \
	fedora-33-ppc64le-qemu \
)
ANSIBLE := $(wildcard ansible/**/*.yml)
CONFIGS := $(wildcard config/*)
BUILT_BOXES = $(wildcard *.box)
# Build headless on the GitHub agents
HEADLESS = $(shell if [ -z "$${GITHUB_REF}" ]; then printf "false"; else printf "true"; fi)

# Returns parts of splits
dash-part = $(word $2,$(subst -, ,$1))

##################
#
## First, how to build boxes
#
##################
all: $(BOXEN)
	@echo ''

ppc: $(PPC_BOXEN)
	@echo ''

fedora-%-ppc64le-qemu.box: boxen.json
	./utils/get_fedora_images.sh $(call dash-part,$@,2) $(call dash-part,$@,3)
	./utils/extend_grub_timeout.sh "$@"
	PACKER_LOG=1 packerio build -parallel-builds=1 -var-file=$(call dash-part,$@,2)_$(call dash-part,$@,3).json -var headless=$(HEADLESS) -only=$(basename $@) $<

%.box: boxen.json
	./utils/get_$(call dash-part,$@,1)_images.sh $(call dash-part,$@,2) $(call dash-part,$@,3)
	PACKER_LOG=1 packerio build -parallel-builds=1 -var-file=$(call dash-part,$@,2)_$(call dash-part,$@,3).json -var headless=$(HEADLESS) -only=$(basename $@) $<

import:
	for box in *.box; do vagrant box add $$(basename $$box) ./$$box; done

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
clean:
	rm -f *.json *.iso *.box *.qcow2 build.* http/cloud-init/config.iso
	rm -rf output-* venv
	sudo umount mnt || true
	rmdir mnt || true
	chmod -R +w new_mnt || true
	rm -rf new_mnt

.PHONY: config.iso all clean import
