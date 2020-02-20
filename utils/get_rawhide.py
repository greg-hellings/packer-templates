#!/usr/bin/env python3
from argparse import ArgumentParser
from progressbar import DataTransferBar, UnknownLength
from urllib.request import urlopen, urljoin, urlretrieve
from urllib.error import URLError, HTTPError
from re import finditer
from sys import exit
import hashlib
import json
import os


# ISO_PATH = 'fedora/linux/development/{}/Server/x86_64/iso/'
# HOST = 'https://download-ib01.fedoraproject.org/pub/'
ISO_PATH = 'fedora/development/{}/Everything/x86_64/iso/'
HOST = 'http://1chronicles/repos/'
PARSER = ArgumentParser(description='Find and download pre-release Fedora')


class ReleaseFinder(object):
    def __init__(self, release):
        self.path = ISO_PATH.format(release)
        self.url = urljoin(HOST, self.path)
        self.regex = r'href="(.*?)"'

    @property
    def page(self):
        print('Fetching list of release ISO files: ', self.url)
        try:
            page = urlopen(self.url)
            charset = page.info().get_content_charset()
            return page.read().decode(charset if charset is not
                                      None else 'utf-8')
        except HTTPError as e:
            print('HTTP error: ', e.code, self.url)
            exit(1)
        except URLError as e:
            print('URL error: ', e.reason, self.url)
            exit(1)

    @property
    def image(self):
        links = [m.group(1) for m in finditer(self.regex, self.page)]
        isos = [l for l in links if l.endswith('.iso')]
        netinst = [i for i in isos if i.find('netinst') != -1]
        if len(netinst) > 0:
            return netinst[0]
        else:
            return None

    def download_iso_file(self):
        self.local_image = self.image
        if self.local_image is None:
            raise Exception("Not suitable ISO image found at {0}"
                            .format(self.url))
        url = urljoin(self.url, self.local_image)
        if os.path.exists(self.local_image):
            print('File already found')
            return
        try:
            with DataTransferBar(max_value=UnknownLength) as bar:
                def update(a, r, t):
                    bar.max_value = t
                    try:
                        bar.update(bar.value + r)
                    except Exception:
                        pass
                urlretrieve(url, self.local_image, update)
                bar.finish()
        except HTTPError as e:
            print('HTTP error: ', e.code, url)
            exit(1)
        except URLError as e:
            print('URL error: ', e.reason, url)
            exit(1)
        else:
            print('Downloaded ' + self.local_image)

    def update_file(self, _file):
        m = hashlib.sha256()
        with open(self.local_image, 'rb') as f:
            for part in iter(f):
                m.update(part)
        print("Found sha256sum as: ", m.hexdigest())
        j = None
        with open(_file, 'r') as f:
            j = json.load(f)
        variables = j['variables']
        variables['iso_url'] = self.local_image
        variables['iso_checksum'] = m.hexdigest()
        variables['iso_checksum_type'] = 'sha256'
        with open(_file, 'w') as f:
            json.dump(j, f, indent=2)


def main():
    PARSER.add_argument('--release', '-r', type=str, default='rawhide')
    PARSER.add_argument('--file', '-f', type=str, default=None)
    args = PARSER.parse_args()
    # Create the proper link
    finder = ReleaseFinder(args.release)
    finder.download_iso_file()
    if args.file is not None:
        finder.update_file(args.file)


if __name__ == '__main__':
    main()
