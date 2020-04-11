from .base import ReleaseFinder


class Archlinux(ReleaseFinder):
    base = 'https://mirrors.kernel.org/archlinux/iso/latest/'

    def __init__(self, version, arch):
        self.distro = 'archlinux'
        super(Archlinux, self).__init__(version, arch)

    def get_image(self):
        '''
        From base class
        '''
        links_page = self.get_page(self.base)
        isos = self.find_links(links_page)
        if len(isos) > 0:
            return isos[0]
        else:
            return None
