(function (socket) {
    'use strict';
    
    var ui = {
        connectForm: document.querySelector('#connect-form')
    };
    
    ui.connectForm.addEventListener('submit', function (event) {
        event.preventDefault();
        socket
	    .sendRpcRequest({
		id: new Date().getTime(),
		method: 'attach-database',
		params: []
	    })
	    .catch(err => console.log(err));
    });
})(Socket);
