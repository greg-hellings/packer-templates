from .base import ReleaseFinder


class Centos(ReleaseFinder):
    host = 'https://yum.tamu.edu/centos/{version}/isos/{arch}/'
    _name = {
       '6': 'minimal',
       '7': 'NetInstall',
       '8': 'boot'
    }

    def __init__(self, version, arch):
        self.distro = 'centos'
        super(Centos, self).__init__(version, arch)

    @property
    def base(self):
        return self.host.format(**self.__dict__)

    def get_image(self):
        '''
        From base class
        '''
        links_page = self.get_page(self.base)
        isos = self.find_links(links_page)
        netinst = [i for i in isos if i.find(self._name[self.version]) != -1]
        if len(netinst) > 0:
            return netinst[0]
        else:
            return None

    def cent6_updates(self, json):
        for builder in json['builders']:
            builder['shutdown_command'] = 'sudo poweroff'
            for idx in range(len(builder['boot_command'])):
                cmd = builder['boot_command'][idx].replace('inst.ks', 'ks')
                cmd = cmd.replace(' biosdevname=0 net.ifnames=0', '')
                builder['boot_command'][idx] = cmd

    def update_file(self, image):
        json = self._read_file(image)
        # CentOS 6 is a little bit different
        if self.version == '6':
            self.cent6_updates(json)
        self._write_file(json)
