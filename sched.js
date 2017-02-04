#!/usr/bin/env node
/** sched.js
 *  The hourly schedular for toggling things on the auto aquaponics system
 *  Henry J Schmale
 *  02-04-2017
 */


require('json-comments');
var path = require('path');
var sqlite3 = require('sqlite3');
var RedisMq = require('rsmq');
var config = require('config');
var db = new sqlite3.Database(path.join(__dirname + '/db/database.sqlite')); 

function cb_Hourly() {

}


setInterval(cb_Hourly, 3600000);
