const cookie = require('cookie');
const WebSocket = require('ws');

const rpc = require('./rpc');
const session = require('./session');

const wss = new WebSocket.Server({ port: process.env.PORT });

wss.on('headers', (headers, req) => {
  const websocketKey = req.headers['sec-websocket-key'];
  const cookies = cookie.parse(req.headers['cookie'] || '');
  const sessionId = session.start(websocketKey, cookies.sessionId);
  headers.push('set-cookie: ' + cookie.serialize('sessionId', sessionId));
});

wss.on('connection', (ws, req) => {
  const websocketKey = req.headers['sec-websocket-key'];
  const sessionId = session.get(websocketKey);
  
  console.log('Connection', websocketKey, sessionId);
  
  ws.on('message', read);
  
  async function read(message) {
    const { id, method, params } = deserialize(message);

    try {
      if (!rpc.has(method)) {
        throw new Error('The specified method does not exist.');
      }
      
      const result = await rpc.get(method)(sessionId, params);
      send({ id, result });
    } catch ({ message }) {
      const error = { 
        code: -32603,
        message 
      };
      
      send({ id, error });
    }
  }
  
  function send(message) {
    ws.send(serialize(message));
  }
});

wss.on('listening', () => {
  console.log(`wss listening on ${process.env.PORT}`);
});

module.exports = wss;

function deserialize(message) {
  return JSON.parse(message);
}

function serialize(message) {
  return JSON.stringify(message);
}