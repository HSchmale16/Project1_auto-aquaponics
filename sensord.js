/*
 * sensord.js
 * Henry J Schmale
 * December 19, 2016
 */

var SerialPort = require('serialport');
var config = require('./config/config.json');

var port = new SerialPort(config.serial.filename, {
    baudRate: config.serial.baudrate,
    parser: SerialPort.parsers.readline('\n')
});




