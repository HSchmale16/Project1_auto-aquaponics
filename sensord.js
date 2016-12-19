/*
 * sensord.js
 */

var SerialPort = require('serialport');
var Readline = SerialPort.parsers.Readline;
var config = require('config');

var port = new SerialPort(config.serial.filename, {
    baudRate: config.serial.baudrate
});
var parser = port.pipe(new Readline());

parser.on('data', console.log);


