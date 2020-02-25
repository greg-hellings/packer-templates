from .centos import Centos
from .debian import Debian
from .fedora import Fedora
from .ubuntu import Ubuntu

finders = {
    'centos': Centos,
    'debian': Debian,
    'fedora': Fedora,
    'ubuntu': Ubuntu
}
