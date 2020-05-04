BOXEN := $(addsuffix .box, fedora-30-x86_64-qemu \
	fedora-31-x86_64-qemu fedora-31-ppc64le-qemu \
	fedora-32-x86_64-qemu fedora-32-ppc64le-qemu \
	fedora-rawhide-x86_64-qemu)
ANSIBLE := $(wildcard ansible/**/*.yml)
CONFIGS := $(wildcard config/*)
RAWHIDE_URL := http://mirror.math.princeton.edu/pub/fedora/linux/development/rawhide/Cloud/x86_64/images/
#RAWHIDE_URL := http://mirror/repos/fedora/development/rawhide/Cloud/x86_64/images/
RAWHIDE_IMAGE := $(shell curl $(RAWHIDE_URL) | grep qcow2 | sed -E -e 's/^.*a href="(.*?\.qcow2)".*$$/\1/')
BUILT_BOXES = $(wildcard *.box)

##################
#
## First, how to build boxes
#
##################
all: $(BOXEN)
	@echo ''

fedora-rawhide-x86_64-qemu.box: boxen.json config.iso rawhide_sha.json
	packerio build -parallel=false -var-file=rawhide_sha.json -only=$(basename $@) $<

%.box: boxen.json config.iso
	packerio build -parallel=false -var-file=rawhide_sha.json -only=$(basename $@) $<

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
	virtualenv venv
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
	echo "{\"rawhide_url\": \"$(RAWHIDE_IMAGE)\", \"rawhide_checksum\": \"$$(sha256sum $(RAWHIDE_IMAGE))\"}" > rawhide_sha.json

clean:
	rm -f boxen.json
	rm -f *.box
	rm -rf output-*
	rm -rf venv
	rm -f *.qcow2
	rm -f build.*  # IDKWTF these things are

.PHONY: config.iso all clean import
