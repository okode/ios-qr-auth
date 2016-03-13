var server = require('http').createServer()
    , WebSocketServer = require('ws').Server
    , wss = new WebSocketServer({ server: server })
    , express = require('express')
    , ejs = require('ejs')
    , crypto = require('crypto')
    , bodyParser = require('body-parser')
    , app = express()
    , port = 80
    , clients = {};

app.set('view engine', 'ejs');
app.set('views', 'views');
app.use(express.static('public'))  
app.use(bodyParser.json()); // support json encoded bodies

server.on('request', app);
server.listen(port, function () { console.log('Listening on ' + server.address().port) });

app.get('/', function(req, res) {
    res.render('index', {token: crypto.randomBytes(32).toString('hex')});
});

app.post('/:token', function(req, res) {
    var token = req.params.token;
    if (clients[token]) {
        clients[token] = {'data' : req.body};
        res.send();
    } else {
        res.status(403).send();
    }
});

wss.on('connection', function(ws) {
    var url = ws.upgradeReq.url;
    var token = url.substr(url.indexOf('=') + 1);
    console.log('WebSocket connection from: ' + token);
    clients[token] = {};

    var id = setInterval(sendFunc(ws, token), 1000);
    console.log('Started client interval');
    
    ws.on('close', function() {
        clearInterval(id);
        console.log('Stopped client interval');
    });
});

var sendFunc = function(ws, token) {
    return function() {
        if (clients[token] && clients[token].data) {
            console.log('Sending to ' + token + ' ' + JSON.stringify(clients[token]));
            ws.send(JSON.stringify(clients[token]), function() { /* ignore errors */ });
            clients[token] = undefined;
        }
    };
};
