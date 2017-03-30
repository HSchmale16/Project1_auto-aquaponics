#!/bin/bash
# Attempts to read the water level

while true
do
    ./sendMsg.js rdWaLvl
    sleep 3
done
