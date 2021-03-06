from .base import ReleaseFinder


class Ubuntu(ReleaseFinder):
    tpls = {
        '16.04': 'http://releases.ubuntu.com/{version}/',
        '18.04': 'http://cdimages.ubuntu.com/releases/{version}/release/'
    }

    def __init__(self, version, arch):
        self.distro = 'ubuntu'
        super(Ubuntu, self).__init__(version, arch)

    @property
    def base(self):
        return self.tpls.get(self.version,
                             self.tpls['18.04']).format(**self.__dict__)

    def get_image(self):
        links_page = self.get_page(self.base)
        isos = self.find_links(links_page)
        for iso in isos:
            if iso.find('server') != -1 and iso.find(self.arch) != -1 and \
                    iso.find('live') == -1:
                return iso
        return None
