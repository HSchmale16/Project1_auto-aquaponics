#!/bin/bash
# Just runs tests to read all sensors

while true
do
    for s in rdAirTm rdHumid rWatThm rdWaLvl
    do
        ./sendMsg.js $s
        echo Request Read From Sensor $s
        sleep 50
    done
done
