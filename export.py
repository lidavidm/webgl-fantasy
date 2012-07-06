#!/usr/bin/python3

import yaml
import json

docs = yaml.safe_load_all(open("data/weapons.yaml"))
data = {}

with open("assets/gamedata/all.json", 'w') as f:
    for doc in docs:
        docid = doc['id']
        del doc['id']
        data[docid] = doc
    f.write(json.dumps(data, indent=4))
