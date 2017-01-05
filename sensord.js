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
var db = new sqlite3.Database(path.join(__dirname + '/db/database.sqlite'));

var rsmq = new RedisSMQ(config.redis);
rsmq.createQueue({qname: config.msgq.reqAction}, cb_createQueue);
rsmq.createQueue({qname: config.msgq.recvSensor}, cb_createQueue);

setInterval(recvMsg, 100);

// contains code that should go in  the database, and the code to relate them.
var codes4db = {};
config.actions.sensor.forEach(function(x){
    codes4db[x.name] = x.code;
});
console.log(codes4db);

var port = new SerialPort(config.serial.filename, {
    baudRate: config.serial.baudrate,
    parser: SerialPort.parsers.readline('\n')
});

port.on("data", cb_HandleSerialData);

function cb_HandleSerialData(data) {
    console.log(data);
    var stmt = db.prepare(
        "INSERT INTO Readings(sensorId, reading) VALUES (?, ?);"
    );
    var fields = data.split(' ');
    if(codes4db[fields[0]]) {
        stmt.run(codes4db[fields[0]], fields[1]);
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
        port.write(resp.message + '\n');
    }
}
