#!/bin/bash
# Generates garbage readings for the database for testing purposes
# Henry J Schmale
# March 10, 2017

while true
do
    echo INSERT INTO Readings\(sensorId, reading\) VALUES \($(($RANDOM % 4 + \
        1)), $(($RANDOM % 100))\)\;
    sleep 1
done | sqlite3 database.sqlite
