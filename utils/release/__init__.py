from .fedora import Fedora
from .ubuntu import Ubuntu

finders = {
    'fedora': Fedora,
    'ubuntu': Ubuntu
}
