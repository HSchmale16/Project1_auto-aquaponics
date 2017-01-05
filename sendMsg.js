#!/usr/bin/env node

/**
 * Sends a message via rsmq to the sensor daemon
 * Henry J Schmale
 * January 4, 2017
 */

require('json-comments');
var RedisSMQ = require('rsmq');
var config = require('./config/config.json');

var rsmq = new RedisSMQ(config.redis);

rsmq.sendMessage({
    qname: config.msgq.reqAction,
    message: process.argv[2]
}, function(err, resp) {
    if(resp)
        console.log("Msg Sent: ID:", resp);
    process.exit(0);
});


