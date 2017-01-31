#!/usr/bin/env python
# countFish.py
# Henry J Schmale
# Counts the number of fish in the aquaponics tank using blob detection
# with OpenCV python bindings

import cv2
import numpy as np
import json
import sys

with open('config/config.json', 'r') as f:
    config = json.load(f)


