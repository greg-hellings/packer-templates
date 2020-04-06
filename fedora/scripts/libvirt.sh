#!/bin/bash

set -e
set -x

if [ "$PACKER_BUILDER_TYPE" != "qemu" ]; then
  exit 0
fi

# It's possible that ipv6 is screwing with us
sudo sysctl net.ipv6.conf.all.disable_ipv6=1
sudo sysctl net.ipv6.conf.default.disable_ipv6=1
sudo sysctl net.ipv6.conf.lo.disable_ipv6=1
