from .base import ReleaseFinder


FEDORA_DEV_VERSIONS = ('32', 'rawhide')


# ISO_PATH = 'fedora/development/{}/Everything/x86_64/iso/'
# HOST = 'http://1chronicles/repos/'
class Fedora(ReleaseFinder):
    dev_path = 'development/{version}/Server/{arch}/iso/'
    rel_path = 'releases/{version}/Server/{arch}/iso/'
    host = 'https://download.fedoraproject.org/pub/fedora/linux'

    def __init__(self, version, arch):
        super().__init__()
        self.version = version
        self.arch = arch

    @property
    def base(self):
        if self.version in FEDORA_DEV_VERSIONS:
            return self.host + '/' + self.dev_path.format(**self.__dict__)
        else:
            return self.host + '/' + self.rel_path.format(**self.__dict__)

    def get_image(self):
        '''
        From base class
        '''
        links_page = self.get_page(self.base)
        isos = self.find_links(links_page)
        netinst = [i for i in isos if i.find('netinst') != -1]
        if len(netinst) > 0:
            return netinst[0]
        else:
            return None
