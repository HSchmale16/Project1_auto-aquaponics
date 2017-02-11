#!/bin/bash
while true
do
    for s in yCiPump yLIghts yAirPump nCiPump nLIghts nAirPump
    do
        echo "Sensor $s"
        ./sendMsg.js $s
        sleep 1
    done
done
