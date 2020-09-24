#!/bin/bash

set -ex

version="${1}"
arch="${2}"
mirror=http://releases.ubuntu.com/
page="${mirror}${version}/"
target="${version}_${arch}.iso"

if [ ! -f "${target}" ]; then
	file=$(curl -L "${page}" | grep "server-${arch}.iso" | grep -E -v '(torrent|zsync)' | head -1 | sed -E -e 's/^.*a href="(.*?\.iso)".*$/\1/')
	curl -o "${target}" "${page}${file}"
fi

./utils/update_sha.sh "${target}"
