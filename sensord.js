#!/usr/bin/env node

/*
 * sensord.js
 * Henry J Schmale
 * December 19, 2016
 */
require('json-comments');

var path = require('path');
var SerialPort = require('serialport');
var RedisSMQ = require('rsmq');
var config = require('./config/config.json');
var sqlite3 = require('sqlite3');
var child_process = require('child_process');

var db = new sqlite3.Database(path.join(__dirname + '/db/database.sqlite'));

var rsmq = new RedisSMQ(config.redis);
rsmq.createQueue({qname: config.msgq.reqAction}, cb_createQueue);
rsmq.createQueue({qname: config.msgq.recvSensor}, cb_createQueue);

setInterval(recvMsg, 100);
// handle setting the actions every 120 seconds
setInterval(handleActions, 60 * 1000);

// contains code that should go in  the database, and the code to relate them.
var codes4db = {};
config.actions.sensor.forEach(function(x){
    codes4db[x.name] = x.code;
});
var validSerialCodes = config.actions.validSerial;

var port = new SerialPort(config.serial.filename, {
    baudRate: config.serial.baudrate,
    parser: SerialPort.parsers.readline('\n')
});

port.on("data", cb_HandleSerialData);

function cb_HandleSerialData(data) {
    console.log(data);

    var fields = data.split(' ');
    if(codes4db[fields[0]]) {
        var stmt = db.prepare(
            "INSERT INTO Readings(sensorId, reading) VALUES (?, ?);"
        );
        stmt.run(codes4db[fields[0]], fields[1]);
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

function recvMsg() {
    rsmq.popMessage({qname: config.msgq.reqAction}, cb_recvMsg);
}

function cb_createQueue(err, resp) {
    console.log(resp);
    if(resp === 1) {
        console.log("created queue");
    }
}

function cb_recvMsg(err, resp) {
    if(resp.id){
        console.log('msg recv.', resp);
        if(validSerialCodes.indexOf(resp.message) !== -1)
            port.write(resp.message + '\n');
        else{
            // handle alternate states like where we need to do blob counting for counting fish
        }
    }
}

function handleActions() {
    child_process.exec(path.join(__dirname, './sched.js'),
                function(err) {
                    if(err) { console.log(err) }
                });
}
