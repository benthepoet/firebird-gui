const WebSocket = require('ws');
const rpc = require('./rpc');

const serverOptions = {
  port: process.env.PORT
};

const wss = new WebSocket.Server(serverOptions);

wss.on('connection', (ws, req) => {
  const wsKey = req.headers['sec-websocket-key'];
  
  ws.on('message', read);
  
  async function read(message) {
    const { id, method, params } = deserialize(message);

    try {
      if (!rpc.has(method)) {
        throw new Error('The specified method does not exist.');
      }
      
      const response = await rpc.get(method)(wsKey, params);
      send({ id, ...response });
    } catch (error) {
      send(error.message);
    }
  }
  
  function send(message) {
    ws.send(serialize(message));
  }
});

wss.on('listening', () => {
  console.log(`wss listening on ${serverOptions.port}`);
});

module.exports = wss;

function deserialize(message) {
  return JSON.parse(message);
}

function serialize(message) {
  return JSON.stringify(message);
}