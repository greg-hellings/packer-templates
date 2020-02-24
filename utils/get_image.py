#!/usr/bin/env python3
from argparse import ArgumentParser
from release import finders


PARSER = ArgumentParser(description='Find and download pre-release Fedora')


def main():
    PARSER.add_argument('--distro', '-d', type=str)
    PARSER.add_argument('--version', '-v', type=str)
    PARSER.add_argument('--arch', '-a', type=str)
    args = PARSER.parse_args()
    # Create the proper link
    finder = finders[args.distro](args.version, args.arch)
    image = finder.get_image()
    finder.download_image_file(image)
    finder.update_file(image)


if __name__ == '__main__':
    main()
