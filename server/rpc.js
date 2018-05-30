const state = require('./state');

const ConnectionState = {
  CLOSED: 'CLOSED',
  OPEN: 'OPEN'
};

module.exports = new Map([
  ['create-database', createDatabase],
  ['connect-database', connectDatabase],
  ['detach-database', detachDatabase],
  ['execute-sql', executeSql]
]);

async function connectDatabase(wsKey, body) {
  requireConnectionState(ConnectionState.CLOSED, wsKey);
  
  state.connections.set(wsKey, Object.create(null));
  return 'database connected';
}

async function createDatabase(wsKey, body) {
  requireConnectionState(ConnectionState.CLOSED, wsKey);
  
  state.connections.set(wsKey, Object.create(null));
  return 'database created';
}

async function detachDatabase(wsKey, body) {
  requireConnectionState(ConnectionState.OPEN, wsKey);
  
  state.connections.delete(wsKey);
  return 'Database connection closed.';
}

async function executeSql(wsKey, body) {
  requireConnectionState(ConnectionState.OPEN, wsKey);
  
  return 'Database connection ready.';
}

function requireConnectionState(connectionState, wsKey) {
  switch (connectionState) {
    case ConnectionState.CLOSED:
      if (state.connections.has(wsKey)) {
        throw new Error('Database connection already open.');
      }
      break;
    case ConnectionState.OPEN:
      if (!state.connections.has(wsKey)) {
        throw new Error('No open database connection.');
      }
      break;
  }
}