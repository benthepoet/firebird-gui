const WebSocket = require('ws');
const dispatcher = require('./dispatcher');

const serverOptions = {
  port: process.env.PORT
};

const wss = new WebSocket.Server(serverOptions);

wss.on('connection', (ws, req) => {
  const wsKey = req.headers['sec-websocket-key'];
  console.log(`connection with ${wsKey}`);
  
  ws.on('message', async message => {
    const response = await dispatcher(wsKey, message);
    ws.send(response);
  });
});

wss.on('listening', () => {
  console.log(`wss listening on ${serverOptions.port}`);
});

module.exports = wss;