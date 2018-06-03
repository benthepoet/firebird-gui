(function (socket) {
  'use strict';
    
  var ui = {
    connectForm: document.querySelector('#connect-form'),
    connectionState: document.querySelector('#connection-state')
  };
    
  ui.connectForm.addEventListener('submit', function (event) {
    event.preventDefault();
    socket
      .sendRpcRequest({
        id: new Date().getTime(),
        method: 'attach-database',
        params: []
      })
      .catch(error => {
        var textNode = document.createTextNode(error);
        ui.connectionState.appendChild(textNode);
      });
  });
})(window.Socket);
