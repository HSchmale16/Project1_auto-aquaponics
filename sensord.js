#!/usr/bin/env node

/*
 * sensord.js
 * Henry J Schmale
 * December 19, 2016
 */

var SerialPort = require('serialport');
var RedisSMQ = require('rsmq');
var config = require('./config/config.json'); 

var rsmq = new RedisSMQ(config.redis);
rsmq.createQueue({qname: config.msgq.reqAction}, cb_createQueue);
rsmq.createQueue({qname: config.msgq.recvSensor}, cb_createQueue);

setInterval(recvMsg, 1000);


var port = new SerialPort(config.serial.filename, {
    baudRate: config.serial.baudrate,
    parser: SerialPort.parsers.readline('\n')
});

port.on("data", console.log);

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
    }else{
        console.log('no msg for me');
    }
}
