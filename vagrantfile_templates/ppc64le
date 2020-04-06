Vagrant.configure('2') do |config|
  7.times do
    config.vm.network :private_network, type: :dhcp
  end

  Pathname.glob('*.json').sort.each do |template|
    name = template.basename('.json').to_s
    escaped_name = name.gsub(/[.]/, '_')

    config.vm.define "#{escaped_name}-libvirt" do |c|
      c.vm.box = name
      c.vm.boot_timeout = 3600  # an hour, because ppc64le can be slow

      c.vm.provider :libvirt do |v, override|
        override.vm.synced_folder '', '/vagrant', disabled: true
        v.driver = 'qemu'
        v.machine_arch = 'ppc64'
        v.machine_type = 'pseries'
        v.cpu_mode = 'custom'
        v.cpu_model = 'power8'
        v.qemuargs :value => '-nodefaults'
        v.qemuargs :value => '-nographic'
      end
    end

    config.vm.define "#{escaped_name}-virtualbox" do |c|
      c.vm.box = name

      c.vm.provider :virtualbox do |v|
        v.name = name
        v.gui = false
      end
    end

    config.vm.define "#{escaped_name}-vmware_fusion" do |c|
      c.vm.box = name

      c.vm.provider :vmware_fusion do |v|
        v.gui = false
      end
    end
  end
end
