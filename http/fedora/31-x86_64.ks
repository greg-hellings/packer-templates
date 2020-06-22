text

url --url=http://mirrors.kernel.org/fedora/releases/$releasever/Everything/$basearch/os/
repo --name=fedora-updates --baseurl=http://mirrors.kernel.org/fedora/updates/$releasever/Everything/$basearch/

%include /tmp/packer_ks/fedora/f31/fedora-cloud-base-vagrant.ks

%pre --interpreter /bin/bash --log /tmp/greg
cmdline=$(cat /proc/cmdline)
ks=$(printf "${cmdline}" | sed -E -e 's/.*inst\.ks=([^ ]*).*/\1/')
mkdir -p /tmp/packer_ks
cd /tmp/packer_ks
wget -m -nH "$(dirname "${ks}")"
%end
