const handlers = {
  'create-database': async () => {
    return 'database created';
  },
  'connect-database': async () => {
    return 'database connected';
  }
};

module.exports = async ({ type, body }) => {
  const handler = handlers[type];
  
  if (handler !== undefined) {
    return await handler(body);
  }
};