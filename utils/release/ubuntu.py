from .base import ReleaseFinder


class Ubuntu(ReleaseFinder):
    base_tpl = 'http://releases.ubuntu.com/{version}/'

    def __init__(self, version, arch):
        self.distro = 'ubuntu'
        super(Ubuntu, self).__init__(version, arch)

    @property
    def base(self):
        return self.base_tpl.format(**self.__dict__)

    def get_image(self):
        links_page = self.get_page(self.base)
        isos = self.find_links(links_page)
        for iso in isos:
            if iso.find('server') != -1 and iso.find(self.arch) != -1:
                return iso
        return None
