const WebSocket = require('ws');
const rpc = require('./rpc');

const serverOptions = {
  port: process.env.PORT
};

const wss = new WebSocket.Server(serverOptions);

wss.on('connection', (ws, req) => {
  const wsKey = req.headers['sec-websocket-key'];
  
  ws.on('message', async ({ method, params }) => {
    if (!rpc.has(method)) {
      ws.send('The specified method does not exist.');
      return;
    }
    
    try {
      const response = await rpc.get(method)(params);
      ws.send(response);
    } catch (error) {
      ws.send(error.message);
    }
  });
});

wss.on('listening', () => {
  console.log(`wss listening on ${serverOptions.port}`);
});

module.exports = wss;