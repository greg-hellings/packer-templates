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
        return '{0}{1:0>2}{2:0>2}'.format(*localtime())

    def get_page(self, url):
        '''
        Fetches the contents of @url and returns the decoded text of the
        remote page. Do not use this for downloading large or binary resources

        :param url: URL to resource to be fetched
        :returns: Decoded text representation of the remote resource
        '''
        print('Fetching page: ', url)
        loops = 0
        while loops < 3:
            try:
                page = urlopen(url)
                charset = page.info().get_content_charset()
                return page.read().decode(charset if charset is not
                                          None else 'utf-8')
            except HTTPError as e:
                print('HTTP error: ', e.code, url)
            except URLError as e:
                print('URL error: ', e.reason, url)
            loops = loops + 1
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

    @property
    def _file(self):
        return '{distro}/{version}-{arch}.json'.format(**self.__dict__)

    def _read_file(self, image):
        '''
        Reads the JSON base file, calculates the SHA256 hash of the given
        @image file, and updates the variables with that information as well as
        a timestamp. Returns the JSON data object.

        :param image: The image file to insert to the JSON data
        :returns: JSON data dict from the file, suitable for passing to
        @_write_file
        '''
        m = hashlib.sha256()
        with open(image, 'rb') as f:
            for part in iter(f):
                m.update(part)
        print("Found sha256sum as: ", m.hexdigest())
        json_data = None
        # Read the template file
        with open(self._file, 'r') as f:
            json_data = json.load(f)
        variables = json_data['variables']
        variables['iso_url'] = os.path.join(os.pardir, image)
        variables['iso_checksum'] = m.hexdigest()
        variables['iso_checksum_type'] = 'sha256'
        variables['timestamp'] = self.timestamp
        variables['{0}_version'.format(self.distro)] = self.version
        return json_data

    def _write_file(self, json_data):
        '''
        Writes the @json_data to the target JSON file

        :param json_data: The updated JSON data, such as that retrieved from
        the @_read_file method
        '''
        # Write the output file
        with open(self._file, 'w') as f:
            json.dump(json_data, f, indent=2)
            print('Wrote', self._file)

    def update_file(self, image):
        '''
        Update the given Packer template with the specified image file.

        Override this method if you have particular data you need to update for
        a given distro

        :param image: The local image file to insert to the JSON file
        :returns: nothing
        '''
        json_data = self._read_file(image)
        json_data['variables']['compression_level'] = '9'
        self._write_file(json_data)
