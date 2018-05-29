const WebSocket = require('ws');

const serverOptions = {
  port: process.env.PORT
};

const wss = new WebSocket.Server(serverOptions);

wss.on('connection', ws => {
  console.log('user connected');
});

wss.on('listening', () => {
  console.log(`wss listening on ${serverOptions.port}`);
});

module.exports = wss;