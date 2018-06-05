const Firebird = require('node-firebird');
const state = require('./state');

const ResultCode = {
  CONNECTED: 0,
  DISCONNECTED: 1,
  QUERY_RESULT: 2
};

const ConnectionState = {
  CLOSED: 'CLOSED',
  OPEN: 'OPEN'
};

module.exports = new Map([
  ['attach-database', attachDatabase],
  ['create-database', createDatabase],
  ['detach-database', detachDatabase],
  ['execute-sql', executeSql]
]);

async function attachDatabase(wsKey, params) {
  requireConnectionState(ConnectionState.CLOSED, wsKey);
  
  const connection = await new Promise((resolve, reject) => {
    Firebird.attach(params, (err, db) => {
      console.log(err);
      err ? reject(err) : resolve(db);
    });
  });
  
  state.connections.set(wsKey, connection);
  
  return {
    code: ResultCode.CONNECTED
  };
}

async function createDatabase(wsKey, params) {
  requireConnectionState(ConnectionState.CLOSED, wsKey);
  
  const connection = await new Promise((resolve, reject) => {
    Firebird.create(params, (err, db) => {
      err ? reject(err) : resolve(db);
    });
  });
  
  state.connections.set(wsKey, connection);
  
  return {
    code: ResultCode.CONNECTED
  };
}

async function detachDatabase(wsKey, params) {
  requireConnectionState(ConnectionState.OPEN, wsKey);
  
  const connection = state.connections.get(wsKey);
  
  await new Promise((resolve, reject) => {
    connection.detach(err => {
      err ? reject(err) : resolve();
    });
  });
  
  state.connections.delete(wsKey);
  
  return {
    code: ResultCode.DISCONNECTED
  };
}

async function executeSql(wsKey, { sql }) {
  requireConnectionState(ConnectionState.OPEN, wsKey);
  
  const connection = state.connections.get(wsKey);
  
  const data = await new Promise((resolve, reject) => {
    connection.execute(sql, (err, result) => {
      err ? reject(err) : resolve(result);
    });
  });

  return {
    code: ResultCode.QUERY_RESULT,
    data
  }
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