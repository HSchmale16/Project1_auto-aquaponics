#!/bin/bash
while true
do
    for s in yCiPump yLIghts yAirPmp nCiPump nLIghts nAirPmp
    do
        echo "Sensor $s"
        ./sendMsg.js $s
        sleep 1
    done
done
