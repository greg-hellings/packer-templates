Vagrant.configure('2') do |c|
  c.vm.synced_folder ".", "/vagrant", type: "rsync"
  # Set some basic overrides
  c.vm.provider :libvirt do |v, override|
    v.driver = 'kvm'
    v.connect_via_ssh = false
    v.username = 'root'
  end
  c.vm.provider :virtualbox do |v|
    v.gui = false
  end
  c.vm.provider :vmware_fusion do |v|
    v.gui = false
  end
end
