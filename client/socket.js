var Socket = (function () {
    var RPC_TIMEOUT = 10000,
        SOCKET_URL = 'ws://localhost:8920',
        rpcHandles,
        ws;
    
    rpcHandles = new Map();
    
    ws = new WebSocket(SOCKET_URL);
    ws.on('message', handleRpcResponse);
    
    return {
        sendRpcRequest: sendRpcRequest
    };
    
    function deserialize(data) {
        return JSON.parse(data);
    }
    
    function handleRpcResponse(data) {
        var message = deserialize(data);
        
        if (message.id !== undefined && message.id !== null) {
            var handle = rpcHandles.get(message.id);
            if (handle !== undefined) {
                console.log('RESOLVED', message.id);
                handle(message);
            }
        }
    }
    
    function sendRpcRequest(message) {
        return new Promise(function (resolve, reject) {
            var data = serialize(message);
            
            rpcHandles.set(message.id, resolve);
            setTimeout(function () {
                reject();
            }, RPC_TIMEOUT);
            
            ws.send(data);
        });
    }
    
    function serialize(message) {
        return JSON.stringify(message);
    }
})();