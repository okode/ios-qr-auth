var fs = require('fs');
var ejs = require('ejs');
var express = require('express');
var crypto = require('crypto');
var webSocketServer = require('ws').Server;
var bodyParser = require('body-parser');

var app = express();
app.set('view engine', 'ejs');
app.set('views', 'views');
app.use(express.static('public'))  
app.use(bodyParser.json()); // support json encoded bodies

app.get('/', function(req, res) {
    res.render('index', {token: crypto.randomBytes(32).toString('hex')});
});

app.post('/:token', function(req, res) {
    var token = req.params.token;
    if (clients[token]) {
        clients[token] = {"data" : req.body};
        res.send();
    } else {
        res.status(403).send();
    }
});

app.listen(3001);

var clients = {};

var wss = new webSocketServer({port:3002});
wss.on('connection', function(ws) {
    var url = ws.upgradeReq.url;
    var token = url.substr(url.indexOf('=') + 1);
    console.log("connection from: " + token);
    clients[token] = {};

    var id = setInterval(sendFunc(ws, token), 1000);
  
    console.log('started client interval');
    ws.on('close', function() {
        console.log('stopping client interval');
        clearInterval(id);
    });
});

var sendFunc = function(ws, token) {
    return function() {
        if (clients[token] && clients[token].data) {
            console.log("sending to " + token + " " + JSON.stringify(clients[token]));
            ws.send(JSON.stringify(clients[token]), function() { /* ignore errors */ });
            clients[token] = undefined;
        }
    };
};
