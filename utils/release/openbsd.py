from .base import ReleaseFinder


class OpenBSD(ReleaseFinder):
    host = 'http://ftp.openbsd.org/pub/OpenBSD/{version}/{arch}/'

    def __init__(self, version, arch):
        self.distro = 'openbsd'
        super(OpenBSD, self).__init__(version, arch)

    @property
    def base(self):
        return self.host.format(**self.__dict__)

    def get_image(self):
        '''
        From base class
        '''
        links_page = self.get_page(self.base)
        isos = self.find_links(links_page)
        cds = [i for i in isos if i.find('cd' + self.version.replace('.', '')) != -1]
        if len(cds) > 0:
            return cds[0]
        else:
            return None
