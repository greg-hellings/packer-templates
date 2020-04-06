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
