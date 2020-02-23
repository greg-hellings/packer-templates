from .fedora import Fedora
from .ubuntu import Ubuntu
from .centos import Centos

finders = {
    'fedora': Fedora,
    'ubuntu': Ubuntu,
    'centos': Centos
}
