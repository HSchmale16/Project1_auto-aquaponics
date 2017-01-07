#!/usr/bin/env python
# countFish.py
# Henry J Schmale
# Counts the number of fish in the aquaponics tank using blob detection
# with OpenCV python bindings

import cv2
import numpy as np

im = cv2.imread("blob.jpg", cv2.IMREAD_GRAYSCALE)
