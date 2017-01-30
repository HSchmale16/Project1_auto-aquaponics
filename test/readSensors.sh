#!/bin/bash
# Just runs tests to read all sensors

while true
do
    for s in rdAirTm rdHumid
    do
        ./sendMsg.js $s
        echo $s
        sleep 1
    done
done
