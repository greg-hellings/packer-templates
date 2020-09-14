#!/bin/bash
# Fetches a Fedora image from one of the oft-changing named image types.
# Basically - from Rawhide or a development branch. Also, creates a JSON
# file with the sha hash defined

set -ex -o pipefail

version="${1}"
arch="${2}"
mirror=http://mirrors.kernel.org
#mirror=http://chronicles/pub

if [ -z "${version}" ]; then
	echo "Usage: "${0}" <rawhide|version> <arch|silverblue>"
	exit 1
fi

function fetch_netinst_url {
	LIST="${1}"
	TARGET="${2}"
	IMAGE="$(curl ${LIST} | grep netinst | head -1 | grep -v manifest | sed -E -e 's/^.*a href="(.*?\.iso)".*$/\1/')"
	if [ ! -f "${TARGET}" ]; then
		curl -C - -o "${TARGET}" "${LIST}${IMAGE}"
	fi
}

function fetch_silverblue_url {
	LIST="${1}"
	TARGET="${2}"
	IMAGE="$(curl ${LIST} | grep ostree | head -1 | sed -E -e 's/^.*a href="(.*?\.iso)".*$/\1/')"
	if [ ! -f "${TARGET}" ]; then
		curl -o "${TARGET}" "${LIST}${IMAGE}"
	fi
}

function fetch_development {
	LIST="${mirror}/fedora/development/"
	DEVS="$(curl ${LIST} | grep -E 'a href="[^\.]{2}' | sed -E -e 's/.*a href="(.*?)".*/\1/')"
	echo "${DEVS}"
}

# ppc64le is a secondary architecture
if [[ "${arch}" == "ppc64le" ]]; then
	release_url="${mirror}/fedora-secondary/"
else
	release_url="${mirror}/fedora/"
fi

# We don't want to update scripts every time there is a new release
dev_versions=$(fetch_development)
if [[ "${dev_versions}" == *"${version}"* ]]; then
	release_url="${release_url}development/${version}/"
else
	release_url="${release_url}releases/${version}/"
fi

# We grab different ISO images for basic vs silverblue
target_name="${version}_${arch}.iso"
if [[ "${arch}" == "silverblue" ]]; then
	release_url="${release_url}Silverblue/x86_64/iso/"
	fetch_silverblue_url "${release_url}" "${target_name}"
else
	release_url="${release_url}Server/${arch}/iso/"
	fetch_netinst_url "${release_url}" "${target_name}"
fi

./utils/update_sha.sh "${target_name}"
