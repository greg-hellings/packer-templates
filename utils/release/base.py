from abc import ABC, abstractmethod
from urllib.request import urlopen, urljoin, urlretrieve
from urllib.error import URLError, HTTPError
from re import finditer
from progressbar import DataTransferBar, UnknownLength
from time import sleep, localtime
import hashlib
import json
import os
import re


class ReleaseFinder(ABC):
    def __init__(self, version, arch):
        self.version = version
        self.arch = arch
        self.regex = r'href="(.*?)"'

    @abstractmethod
    def get_image(self):
        '''
        Downloads the image from the remote source and returns the local file
        name of the downloaded image for the caller to process.

        Must be implemented by the subclass.

        :returns: Local path to the downloaded image file
        '''
        pass

    @property
    @abstractmethod
    def base(self):
        '''
        Identifies the base of all URL operations

        :returns: The URL base against whence images are downloaded
        '''
        pass

    @property
    def timestamp(self):
        return '{0}{1}{2}'.format(*localtime())

    def get_page(self, url):
        '''
        Fetches the contents of @url and returns the decoded text of the
        remote page. Do not use this for downloading large or binary resources

        :param url: URL to resource to be fetched
        :returns: Decoded text representation of the remote resource
        '''
        print('Fetching page: ', url)
        try:
            page = urlopen(url)
            charset = page.info().get_content_charset()
            return page.read().decode(charset if charset is not
                                      None else 'utf-8')
        except HTTPError as e:
            print('HTTP error: ', e.code, url)
        except URLError as e:
            print('URL error: ', e.reason, url)
        return ''

    def find_links(self, page, suffix='.iso$'):
        '''
        Finds all href="..." attribute values with a simple brute-force regex
        and then looks for any that end with the given suffix.

        :param page: The text to search
        :param suffix: The file suffix on any links to search for
        :returns: (possibly empty) list of links that match the given suffix
        '''
        links = [m.group(1) for m in finditer(self.regex, page)]
        isos = [l for l in links if re.search(suffix, l) is not None]
        return isos

    def download_image_file(self, image):
        '''
        Downloads the @image from the base URL location to the cwd.

        :param image: the filename portion of the URL to download and the local
        name the file will be downloaded to
        :returns: nothing
        '''
        if image is None:
            raise Exception("No suitable ISO image found at {0}"
                            .format(self.base))
        url = urljoin(self.base, image)
        if os.path.exists(image):
            print('File already found')
            return
        with DataTransferBar(max_value=UnknownLength) as bar:
            def update(a, r, t):
                bar.max_value = t
                try:
                    bar.update(bar.value + r)
                except Exception:
                    pass
            retries = 20
            while retries > 0:
                try:
                    print("Fetching: ", image)
                    bar.update(0)
                    urlretrieve(url, image, update)
                except HTTPError as e:
                    print('HTTP error: ', e.code, url)
                    retries = retries - 1
                    sleep(1)
                    continue
                except URLError as e:
                    print('URL error: ', e.reason, url)
                    retries = retries - 1
                    sleep(1)
                    continue
                else:
                    break
            bar.finish()

    def update_file(self, image):
        '''
        Update the given Packer template with the specified image file.

        :param _file: The name of the JSON file to update
        :param image: The local image file to insert to the JSON file
        :returns: nothing
        '''
        m = hashlib.sha256()
        with open(image, 'rb') as f:
            for part in iter(f):
                m.update(part)
        print("Found sha256sum as: ", m.hexdigest())
        j = None
        # Read the template file
        _file = '{0}.json'.format(self.distro)
        with open(_file, 'r') as f:
            j = json.load(f)
        variables = j['variables']
        variables['iso_url'] = image
        variables['iso_checksum'] = m.hexdigest()
        variables['iso_checksum_type'] = 'sha256'
        variables['timestamp'] = self.timestamp
        variables['{0}_version'.format(self.distro)] = self.version
        # Write the output file
        _newfile = "{distro}-{version}-{arch}.json".format(**self.__dict__)
        with open(_newfile, 'w') as f:
            json.dump(j, f, indent=2)
