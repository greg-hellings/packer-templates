#!/usr/bin/env python3
from argparse import ArgumentParser
from release import finders
from os.path import splitext


PARSER = ArgumentParser(description='Find and download pre-release Fedora')


def main():
    PARSER.add_argument('--file', '-f', type=str)
    args = PARSER.parse_args()
    distro, version, arch = splitext(args.file)[0].split('-')
    # Create the proper link
    finder = finders[distro](version, arch)
    image = finder.get_image()
    finder.download_image_file(image)
    if args.file is not None:
        finder.update_file(args.file, image)


if __name__ == '__main__':
    main()
