var WebSocketServer = require('ws').Server,

wss = new WebSocketServer({ port: 1358 });
wss.on('connection', function (ws) {
    console.log('client connected');

    ws.send('you is' + wss.clients.length + 'number');  
    //receive message callback
    ws.on('message', function (message) {
        console.log(message);
        ws.send('receive:'+message);  
    });

     // exit chat
    ws.on('close', function(close) {  
      
        console.log('exit connect');  
    });  
});
console.log('start monitor 1358 port');