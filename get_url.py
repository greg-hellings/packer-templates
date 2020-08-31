#!/usr/bin/python3
import json
import sys

name = sys.argv[1]
with open('boxen.json', 'r') as inf:
    loaded = json.load(inf)
for builder in loaded['builders']:
    if builder['name'] == name:
        print(builder['iso_url'])
        break
