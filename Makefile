BOXEN := $(addsuffix .box, fedora-30-x86_64-qemu \
	fedora-31-x86_64-qemu fedora-31-ppc64le-qemu \
	fedora-32-x86_64-qemu fedora-32-ppc64le-qemu \
	fedora-rawhide-x86_64-qemu)
ANSIBLE := $(wildcard ansible/**/*.yml)
CONFIGS := $(wildcard config/*)
RAWHIDE_URL := http://mirrors.kernel.org/fedora/development/rawhide/Server/x86_64/iso/
RAWHIDE_IMAGE := $(shell curl $(RAWHIDE_URL) | grep netinst | grep -v manifest | sed -E -e 's/^.*a href="(.*?\.iso)".*$$/\1/')
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

fedora-rawhide-x86_64-qemu.box: boxen.json config.iso rawhide_sha.json
	PACKER_LOG=1 packerio build -parallel-builds=1 -var-file=rawhide_sha.json -var headless=$(HEADLESS) -only=$(basename $@) $<

%.box: boxen.json config.iso
	PACKER_LOG=1 packerio build -parallel-builds=1 -var headless=$(HEADLESS) -only=$(basename $@) $<

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
$(RAWHIDE_IMAGE):
	curl -o $(RAWHIDE_IMAGE) $(RAWHIDE_URL)$(RAWHIDE_IMAGE)

rawhide_sha.json: $(RAWHIDE_IMAGE)
	echo "{\"rawhide_url\": \"$(RAWHIDE_IMAGE)\", \"rawhide_checksum\": \"sha256:$$(sha256sum $(RAWHIDE_IMAGE) | cut -d' ' -f 1)\"}" > rawhide_sha.json

clean:
	rm -f boxen.json
	rm -f *.box
	rm -rf output-*
	rm -rf venv
	rm -f *.qcow2
	rm -f build.*  # IDKWTF these things are

.PHONY: config.iso all clean import
