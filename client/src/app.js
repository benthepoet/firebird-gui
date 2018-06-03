var socket = require('./socket');

var ui = {
  connectForm: document.querySelector('#connect-form'),
  connectionState: document.querySelector('#connection-state')
};
  
ui.connectForm.addEventListener('submit', function (event) {
  event.preventDefault();

  const params = {
    host: document.querySelector('[name=host]').value,
    database: document.querySelector('[name=database]').value,
    user: document.querySelector('[name=user]').value,
    password: document.querySelector('[name=password]').value
  };

  socket
    .sendRpcRequest({
      id: new Date().getTime(),
      method: 'attach-database',
      params: params
    })
    .then(result => {
      var textNode = document.createTextNode(result.code);
      ui.connectionState.appendChild(textNode);
    })
    .catch(error => {
      console.log(error);
      var textNode = document.createTextNode(error.code);
      ui.connectionState.appendChild(textNode);
    });
});