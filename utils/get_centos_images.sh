#!/bin/bash

version="${1}"
arch="${2}"
mirror=http://mirror.centos.org/centos/

case "${version}" in
	6)
		mirror="${mirror}${version}/"
		search=netinstall
		;;
	7)
		mirror="${mirror}${version}/"
		search=NetInstall
		;;
	8)
		mirror="${mirror}${version}/"
		search=dvd1
		;;
	8_stream)
		mirror="${mirror}8-stream/"
		search=boot
		;;
	*)
		echo "Version unknown"
		exit 1
		;;
esac

mirror="${mirror}isos/${arch}/"
dest="${version}_${arch}.iso"

image="$(curl -L "${mirror}" | grep "${search}" | grep -v torrent | head -1 | sed -E -e 's/.*a href="([^"]*?iso)".*/\1/')"

if [ ! -f "${dest}" ]; then
	curl -L -o "${dest}" "${mirror}${image}"
fi

./utils/update_sha.sh "${dest}"
