#!/usr/bin/python3

import yaml
import json


data = {}


def process_docs(kind, path, data):
    for doc in yaml.safe_load_all(open(path)):
        docid = doc['id']
        doc['type'] = kind
        data[docid] = doc


with open("assets/gamedata/all.json", 'w') as f:
    for kind, path in [
        ("weapon", "data/weapons.yaml"),
        ("dialogue", "data/dialogue.yaml"),
        ("npc", "data/npcs.yaml")]:
        process_docs(kind, path, data)

    f.write(json.dumps(data, indent=4))
