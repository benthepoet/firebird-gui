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
	    .catch(err => {
		var textNode = document.createTextNode('err');
		ui.connectionState.appendChild(textNode);
	    });
    });
})(Socket);
