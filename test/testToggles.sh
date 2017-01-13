#!/bin/bash
while true
do
    case $(($RANDOM % 3)) in
    0)
        ./sendMsg.js tCiPump
        ;;
    1)
        ./sendMsg.js tLights
        ;;
    2)
        ./sendMsg.js tAirPmp
        ;;
    esac
    sleep 1
done
