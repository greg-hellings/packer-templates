import re
from .base import ReleaseFinder


class Debian(ReleaseFinder):
    host = 'https://cdimage.debian.org/'
    slug = {
        'current': 'debian-cd/current/{arch}/iso-cd/',
        'oldold': 'cdimage/archive/latest-oldoldstable/{arch}/iso-cd/',
        'old': 'cdimage/archive/latest-oldstable/{arch}/iso-cd/'
    }
    _name = {
       'current': r'debian-[0-9\.]*-{arch}-netinst.iso',
       'oldold': 'netinst',
       'old': 'netinst'
    }

    def __init__(self, version, arch):
        self.distro = 'debian'
        self.name_version = version
        super(Debian, self).__init__(version, arch)

    @property
    def base(self):
        return (self.host + self.slug[self.name_version])\
               .format(**self.__dict__)

    def get_image(self):
        '''
        From base class
        '''
        links_page = self.get_page(self.base)
        isos = self.find_links(links_page)
        search = self._name[self.name_version].format(**self.__dict__)
        netinst = [i for i in isos if re.search(search, i) is not None][0]
        # Brief detor to split out the numerical version
        parts = netinst.split('-')
        version = parts[1]  # decode the version
        self.version = version.split('.')[0]
        # Return the image name
        return netinst

    def debian8_updates(self, json):
        for builder in json['builders']:
            # Upload the VMWare Tools
            if builder['type'] == 'vmware-iso':
                builder['tools_upload_flavor'] = 'linux'
            # Strip out net.ifnames=0 from boot command in Debian 8
            for idx in range(len(builder['boot_command'])):
                cmd = builder['boot_command'][idx].replace('net.ifnames=0', '')
                builder['boot_command'][idx] = cmd
        # Point to Debian-8 specific VMWare tools
        for prov in json['provisioners']:
            if prov['type'] == 'shell':
                for idx in range(len(prov['scripts'])):
                    cmd = prov['scripts'][idx].replace('/vmware.sh',
                                                       '-8/vmware.sh')
                    prov['scripts'][idx] = cmd

    def update_file(self, image):
        json = self._read_file(image)
        # Debian 8 needs a little TLC
        if self.version == '8':
            self.debian8_updates(json)
        self._write_file(json)
