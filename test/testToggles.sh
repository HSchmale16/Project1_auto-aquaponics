#!/bin/bash
while true
do
    for s in tCiPump tLIghts tAirPump
    do
        echo "Sensor $s"
        ./sendMsg.js $s
        sleep 1
    done
done
