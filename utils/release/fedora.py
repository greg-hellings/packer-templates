from .base import ReleaseFinder


class Fedora(ReleaseFinder):
    dev_path = 'development/{version}/Server/{arch}/iso/'
    rel_path = 'releases/{version}/Server/{arch}/iso/'
    host = 'https://mirrors.kernel.org/fedora'

    def __init__(self, version, arch):
        self.distro = 'fedora'
        super(Fedora, self).__init__(version, arch)

        dev_page = self.get_page(self.host + '/development')
        self.dev = self.find_links(dev_page, r'\d+/')
        self.dev = [d.strip('/') for d in self.dev]
        self.dev.append('rawhide')
        print(self.dev)

    @property
    def base(self):
        if self.version in self.dev:
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
