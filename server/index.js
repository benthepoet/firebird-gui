const WebSocket = require('ws');
const dispatcher = require('./dispatcher');

const serverOptions = {
  port: process.env.PORT
};

const wss = new WebSocket.Server(serverOptions);

wss.on('connection', ws => {
  console.log('user connected');
  
  ws.on('message', async message => {
    const response = await dispatcher(message);
    ws.send(response);
  });
});

wss.on('listening', () => {
  console.log(`wss listening on ${serverOptions.port}`);
});

module.exports = wss;