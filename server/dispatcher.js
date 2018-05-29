const { connections } = require('./state');

const ConnectionState = {
  CLOSED: 'CLOSED',
  OPEN: 'OPEN'
};

const requireConnectionState = (state, wsKey) => {
  switch (state) {
    case ConnectionState.CLOSED:
      if (connections.has(wsKey)) {
        throw new Error('Database connection already open.');
      }
      break;
    case ConnectionState.OPEN:
      if (!connections.has(wsKey)) {
        throw new Error('No open database connection.');
      }
      break;
  }
};

const handlers = {
  'create-database': async (wsKey, body) => {
    requireConnectionState(ConnectionState.CLOSED, wsKey);
    
    connections.set(wsKey, Object.create(null));
    return 'database created';
  },
  'connect-database': async (wsKey, body) => {
    requireConnectionState(ConnectionState.CLOSED, wsKey);
    
    connections.set(wsKey, Object.create(null));
    return 'database connected';
  },
  'detach-database': async (wsKey, body) => {
    requireConnectionState(ConnectionState.OPEN, wsKey);
    
    connections.delete(wsKey);
    return 'Database connection closed.';
  },
  'execute-sql': async (wsKey, body) => {
    requireConnectionState(ConnectionState.OPEN, wsKey);
    
    return 'Database connection ready.';
  }
};

module.exports = async (wsKey, { type, body }) => {
  const handler = handlers[type];
  
  if (handler !== undefined) {
    try {
      return await handler(wsKey, body);
    } catch (error) {
      return error.message;
    }
  }
};