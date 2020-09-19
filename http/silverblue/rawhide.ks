ignoredisk --only-use=vda
autopart --type=lvm
# Partition clearing information
clearpart --none --initlabel
# OSTree setup
ostreesetup --osname="fedora" --remote="fedora" --url="file:///ostree/repo" --ref="fedora/rawhide/x86_64/silverblue" --nogpg
# Use graphical install
text
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Firewall configuration
firewall --use-system-defaults
# Network information
network --bootproto=dhcp --device=link --activate --onboot=on --hostname=localhost.localdomain
# Root password
rootpw vagrant
# X Window System configuration information
# xconfig  --startxonboot
# Run the Setup Agent on first boot
firstboot --enable
# System services
services --enabled="sshd,chronyd"
# System timezone
timezone --utc Etc/UTC
user --groups=wheel,sudo --name=vagrant --password=vagrant

reboot

%post --erroronfail

sed -i 's,Defaults\\s*requiretty,Defaults !requiretty,' /etc/sudoers
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant-nopasswd
sed -i 's/.*UseDNS.*/UseDNS no/' /etc/ssh/sshd_config
mkdir -m 0700 -p ~vagrant/.ssh
cat > ~vagrant/.ssh/authorized_keys << EOKEYS
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOKEYS
chmod 600 ~vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant ~vagrant/.ssh/

%end
