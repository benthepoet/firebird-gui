const cuid = require('cuid');

const websocketSessions = new Map();

module.exports = {
  get,
  start
};

function get(websocketKey) {
  return websocketSessions.get(websocketKey);
}

function start(websocketKey, sessionId) {
  if (!websocketSessions.has(websocketKey)) {
    websocketSessions.set(websocketKey, sessionId || cuid());
  }
  return websocketSessions.get(websocketKey);
}