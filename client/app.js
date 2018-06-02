(function () {
    'use strict';
    
    var socket = Socket();
    
    var ui = {
        connectForm: document.querySelect('#connectForm')
    };
    
    ui.connectForm.addEventListener('submit', function (event) {
        event.preventDefault();
        socket.sendRpcRequest(new Date().getTime(), null, null);
    });
})();