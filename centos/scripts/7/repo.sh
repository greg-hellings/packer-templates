#!/bin/bash

set -e
set -x

sudo yum -y install epel-release
sudo sed -i -e 's/^enabled=1/enabled=0/' /etc/yum.repos.d/epel.repo
