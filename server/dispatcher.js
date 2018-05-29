const { connections } = require('./state');

const handlers = {
  'create-database': async (wsKey, body) => {
    if (connections.has(wsKey)) {
      return 'Database connection already open.';
    }
    
    connections.set(wsKey, Object.create(null));
    return 'database created';
  },
  'connect-database': async (wsKey, body) => {
    if (connections.has(wsKey)) {
      return 'Database connection already open.';
    }
    
    connections.set(wsKey, Object.create(null));
    return 'database connected';
  },
  'detach-database': async (wsKey, body) => {
    if (!connections.has(wsKey)) {
      return 'No open database connection.';
    }
    
    connections.delete(wsKey);
    return 'Database connection closed.';
  },
  'execute-sql': async (wsKey, body) => {
    if (!connections.has(wsKey)) {
      return 'No open database connection.';
    }
    
    return 'Database connection ready.';
  }
};

module.exports = async (wsKey, { type, body }) => {
  const handler = handlers[type];
  
  if (handler !== undefined) {
    return await handler(wsKey, body);
  }
};