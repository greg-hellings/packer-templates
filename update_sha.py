#!/usr/bin/python3
import os
import sys
import json


with open('boxen.json', 'r') as inf:
    loaded = json.load(inf)
image = None
for builder in loaded['builders']:
    if builder['name'] == sys.argv[1]:
        image = builder
        break
if image is None:
    print("No builder found")
    sys.exit(1)
image['iso_url'] = os.path.basename(image['iso_url'])
image['iso_checksum'] = 'sha256:' + sys.argv[2]
with open('boxen.json', 'w') as inf:
    json.dump(loaded, inf, indent=4)
