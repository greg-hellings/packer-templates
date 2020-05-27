Vagrant.configure('2') do |config|
  config.vm.provider :libvirt do |v, override|
    override.vm.synced_folder '', '/vagrant', disabled: true
    v.driver = 'qemu'
    v.machine_arch = 'ppc64'
    v.machine_type = 'pseries'
    v.cpu_mode = 'custom'
    v.cpu_model = 'POWER8'
    v.video_type = 'vga'
    #v.qemuargs :value => '-nodefaults'
    #v.qemuargs :value => '-nographic'
  end
end
