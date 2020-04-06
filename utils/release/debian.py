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

    @property
    def _file(self):
        return '{distro}/{name_version}-{arch}.json'.format(**self.__dict__)
