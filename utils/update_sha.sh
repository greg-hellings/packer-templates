#!/bin/bash

target_name="${1}"

# packer wants to know the SHA256 value of the box
sha="$(sha256sum "${target_name}" | cut -d' ' -f1 )"
cat << EOF > "${target_name%iso}json"
{"${target_name%.iso}_checksum": "sha256:${sha}"}
EOF
cat "${target_name%iso}json"
