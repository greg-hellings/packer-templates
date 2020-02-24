#!/bin/bash

set -e
set -x

if [ x"$(rpm -E %{rhel})" == x6 ]; then
	sudo sed -i -e 's,^ACTIVE_CONSOLES=.*$,ACTIVE_CONSOLES=/dev/tty1,' /etc/sysconfig/init
fi
