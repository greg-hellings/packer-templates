from .archlinux import Archlinux
from .centos import Centos
from .debian import Debian
from .fedora import Fedora
from .freebsd import FreeBSD
from .ubuntu import Ubuntu

finders = {
    'archlinux': Archlinux,
    'centos': Centos,
    'debian': Debian,
    'fedora': Fedora,
    'freebsd': FreeBSD,
    'ubuntu': Ubuntu
}
