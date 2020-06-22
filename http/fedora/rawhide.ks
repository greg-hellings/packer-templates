text

repo --name=fedora --baseurl=http://download-ib01.fedoraproject.org/pub/fedora/linux/development/rawhide/Everything/$basearch/os/

%include /tmp/packer_ks/fedora/ks/fedora-cloud-base-vagrant.ks

%pre --interpreter /bin/bash --log /tmp/greg
cmdline=$(cat /proc/cmdline)
ks=$(printf "${cmdline}" | sed -E -e 's/.*inst\.ks=([^ ]*).*/\1/')
mkdir -p /tmp/packer_ks
cd /tmp/packer_ks
wget -m -nH "$(dirname "${ks}")"
%end
