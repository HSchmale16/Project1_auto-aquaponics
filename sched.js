#!/usr/bin/env node
/** sched.js
 *  The hourly schedular for toggling things on the auto aquaponics system
 *  Henry J Schmale
 *  02-04-2017
 */


require('json-comments');
var path = require('path');
var sqlite3 = require('sqlite3');
var config = require('./config/config.json');
var db = new sqlite3.Database(path.join(__dirname + '/db/database.sqlite')); 
var child_process = require('child_process');

function sqlcb_actionToggle(err, row){
    if(err)
        return;
    var s;
    if(row.state == 0) {
        s = 'n' + row.name;
    } else {
        s = 'y' + row.name;
    }
    child_process.exec(path.join(__dirname, '/sendMsg.js') + ' ' + s,
    function(err) {
        if(err) { console.log(err) }
    })
}

function toggleActionsOnOff() {
    var date = new Date();
    db.each("SELECT * FROM vScheduleState WHERE hours = " + date.getHours(),
            sqlcb_actionToggle);
}

toggleActionsOnOff();
