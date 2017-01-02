#!/usr/bin/env node

var RedisSMQ = require('rsmq');
var config = require('./config/config.json');

var rsmq = new RedisSMQ(config.redis);

console.log(process.argv);

rsmq.sendMessage({
    qname: config.msgq.reqAction,
    message: process.argv[2]
}, function(err, resp) {
    if(resp)
        console.log("Msg Sent: ID:", resp);
    process.exit(0);
});


