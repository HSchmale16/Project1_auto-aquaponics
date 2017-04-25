#!/usr/bin/env node
"use strict";

/*
 * sensord.js
 * Henry J Schmale
 * December 19, 2016
 */

// allows comments in the json config files
require('json-comments');

var path = require('path');
var SerialPort = require('serialport');
var RedisSMQ = require('rsmq');
var config = require('./config/config.json');
var sqlite3 = require('sqlite3');
var child_process = require('child_process');
var nodemailer = require('nodemailer');
var ejs = require('ejs');

var db = new sqlite3.Database(path.join(__dirname + '/db/database.sqlite'));

var rsmq = new RedisSMQ(config.redis);
rsmq.createQueue({qname: config.msgq.reqAction}, cb_createQueue);
rsmq.createQueue({qname: config.msgq.recvSensor}, cb_createQueue);

// poll for messages every 50 milliseconds
setInterval(recvMsg, 50);
// handle setting the actions every 3600 seconds
setInterval(handleActions, 60 * 60 * 1000);
handleActions();

// update the constraints
// poll every minute
setInterval(updateConstraints, 60 * 100);

// Relates the sensor codes to the database codes
var codes4db = {};
var constraintCodes = {};
config.actions.sensor.forEach(function(x){
    codes4db[x.name] = x.code;
    constraintCodes[x.name] = {low: 0, high: 100}
    constraintCodes[x.constraint] = x.name;
});
var validSerialCodes = config.actions.validSerial;

// Open up the serial port for communication with the arduino
// The port splits messages on newlines
var port = new SerialPort(config.serial.filename, {
    baudRate: config.serial.baudrate,
    parser: SerialPort.parsers.readline('\n')
});

port.on("data", cb_HandleSerialData);

/*
 * callback for recieving data over the serial port
 * Handles inserts into the database.
 */
function cb_HandleSerialData(data) {
    console.log(data);

    var fields = data.split(' ');
    if(codes4db[fields[0]]) {
        var stmt = db.prepare(
            "INSERT INTO Readings(sensorId, reading) VALUES (?, ?);"
        );
        stmt.run(codes4db[fields[0]], fields[1]);
        if(checkConstraint(fields[0], Number(fields[1]))){
            handleOutOfBounds(fields[0], fields[0]);
        }
        return;
    }
    if(fields[0] === 'tCiPump') {
        db.run("INSERT INTO ActionLog(actionId) VALUES (1)");
    }else if(fields[0] === 'tAirPmp') {
        db.run("INSERT INTO ActionLog(actionId) VALUES (2)");
    }else if(fields[0] === 'tLights') {
        db.run("INSERT INTO ActionLog(actionId) VALUES (3)");
    }
}

/*
 * Handles the event if a sensor returns a value that is out of bounds
 * for the constriant
 */
function handleOutOfBounds(code, value) {

}

/**
 * Checks that a constraint is in bounds
 * code - sensor code
 * val - value to check
 */
function checkConstraint(code, val) {
    function between(x, l, h) {
        return (x >= l) && (x <= h)
    }
    var con = constraintCodes[code];
    return !between(val, con.low, con.high)
}

function recvMsg() {
    rsmq.popMessage({qname: config.msgq.reqAction}, cb_recvMsg);
}

/*
 * Callback for when a queue is created
 */
function cb_createQueue(err, resp) {
    console.log(resp);
    if(resp === 1) {
        console.log("created queue");
    }
}

/*
 * callback function for recieving a message from the redis message queue
 */
function cb_recvMsg(err, resp) {
    if(resp.id){
        console.log('msg recv.', resp);
        if(validSerialCodes.indexOf(resp.message) !== -1)
            port.write(resp.message + '\n');
        else{
            // handle alternate states like where we need to do blob counting
            // for counting fish
        }
    }
}

/*
 * load up the new constraints
 */
function updateConstraints() {
    db.each("SELECT * FROM vCurrentConstraints", (err, row) => {
        // flip flop from the constraint name to the sensor code
        constraintCodes[constraintCodes[row.name]] = {
            low: Number(row.low),
            high: Number(row.high)
        }
    });
}


/*
 * Runs the script for handling the various actions
 */
function handleActions() {
    child_process.exec(path.join(__dirname, './sched.js'),
                function(err) {
                    if(err) { console.log(err) }
                });
}
