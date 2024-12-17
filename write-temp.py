#!/bin/python

import json
import os
import time
from subprocess import call

def clear_file(filename):
    with open(filename, 'w') as f:
        f.truncate(0)

file1 = "/tmp/gpu_hotspot_temperature.txt"

call('/home/zero/gputemps-adlx/get-temps.sh > /tmp/temps.txt', shell=True)

time.sleep(1)

with open('/tmp/temps.txt', 'r') as json_file:
    data = json.load(json_file)

# Clear the contents of the output files if they exist
if os.path.exists(file1):
    clear_file(file1)

# Write the values to the files
with open(file1, 'w') as f1:
    f1.write(f"{data['GPU Hotspot Temperature']}")
