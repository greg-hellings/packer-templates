from .base import ReleaseFinder


class FreeBSD(ReleaseFinder):
    host = 'http://ftp.freebsd.org/pub/FreeBSD/releases/ISO-IMAGES/'

    def __init__(self, version, arch):
        self.distro = 'freebsd'
        super(FreeBSD, self).__init__(version, arch)
        # Fetch the full vesrion
        versions_page = self.get_page(self.host)
        versions = self.find_links(versions_page, self.version)
        print(versions)
        versions.sort()
        print(versions)
        self.host = self.host + versions[-1] + '/'

    @property
    def base(self):
        return self.host.format(**self.__dict__)

    def get_image(self):
        '''
        From base class
        '''
        links_page = self.get_page(self.base)
        isos = self.find_links(links_page)
        amd64s = [i for i in isos if i.find('amd64') != -1]
        discs = [i for i in amd64s if i.find('disc1') != -1]
        if len(discs) > 0:
            return discs[0]
        else:
            return None
