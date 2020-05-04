#!/usr/bin/env python

import sys
import yaml
import json


if len(sys.argv) != 3:
    print("Must supply arguments: infile outfile")
    sys.exit(1)

# Load file
with open(sys.argv[1], 'r') as inf:
    loaded = yaml.load(inf, Loader=yaml.FullLoader)
# Remove my custom mixins
keys = list(loaded.keys())
for k in keys:
    if k[0] == '_':
        del loaded[k]
# Write resulting file to output
with open(sys.argv[2], 'w') as outf:
    json.dump(loaded, outf, indent=4)
