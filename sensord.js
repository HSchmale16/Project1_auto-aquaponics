/*
 * sensord.js
 */

var SerialPort = require('serialport');

var port = new SerialPort(config.serial.filename, {
    baudRate: config.serial.baudrate
