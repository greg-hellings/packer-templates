#!/bin/bash
# Fetches a Fedora image from one of the oft-changing named image types.
# Basically - from Rawhide or a development branch. Also, creates a JSON
# file with the sha hash defined
#

set -ex -o pipefail

VERSION="${1}"
MIRROR=http://mirrors.kernel.org

if [ -z "${VERSION}" ]; then
	echo "Usage: "${0}" <rawhide|version>"
	exit 1
fi

function fetch_netinst_url {
	LIST="${1}"
	TARGET="${2}"
	IMAGE="$(curl ${LIST} | grep netinst | grep -v manifest | sed -E -e 's/^.*a href="(.*?\.iso)".*$/\1/')"
	curl -C - -o "${TARGET}" "${LIST}${IMAGE}"
}

function fetch_silverblue_url {
	LIST="${1}"
	TARGET="${2}"
	IMAGE="$(curl ${LIST} | grep ostree | sed -E -e 's/^.*a href="(.*?\.iso)".*$/\1/')"
	curl -o "${TARGET}" "${LIST}${IMAGE}"
}

case "${VERSION}" in
	rawhide)
		RELEASE_URL="${MIRROR}/fedora/development/rawhide/Server/x86_64/iso/"
		TARGET_NAME=rawhide.iso
		;;
	rawhide-silverblue)
		RELEASE_URL="${MIRROR}/fedora/development/rawhide/Silverblue/x86_64/iso/"
		TARGET_NAME=rawhide_silverblue.iso
		;;
	rawhide-ppc64le)
		RELEASE_URL="${MIRROR}/fedora-secondary/development/rawhide/Server/ppc64le/iso/"
		TARGET_NAME=rawhide_ppc.iso
		;;
	f??)
		RELEASE_URL="${MIRROR}/fedora/development/${VERSION#f}/Server/x86_64/iso/"
		TARGET_NAME="${VERSION}.iso"
		;;
	f??-silverblue)
		RELEASE_URL="${MIRROR}/fedora/development/${VERSION#f}/Silverblue/x86_64/iso/"
		TARGET_NAME="${VERSION}_silverblue.iso"
		;;
	f??-ppc64le)
		BASE_VER="${VERSION%-ppc64le}"
		RELEASE_URL="${MIRROR}/fedora-secondary/development/${BASE_VER#f}/Server/ppc64le/iso/"
		TARGET_NAME="${VERSION}_ppc.iso"
		;;
	*)
		echo "Version not recognized."
		exit 1
		;;
esac

case "${VERSION}" in
	*silverblue*)
		fetch_silverblue_url "${RELEASE_URL}" "${TARGET_NAME}"
		;;
	*)
		fetch_netinst_url "${RELEASE_URL}" "${TARGET_NAME}"
		;;
esac

SHA="$(sha256sum "${TARGET_NAME}" | cut -d' ' -f1 )"
cat << EOF > "${TARGET_NAME%iso}json"
{"${TARGET_NAME%.iso}_checksum": "sha256:${SHA}"}
EOF
