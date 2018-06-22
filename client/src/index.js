// Import modules
require('animate.css/animate.css');
require('mini.css/dist/mini-default.css');

var CodeMirror = require('codemirror');
require('codemirror/lib/codemirror.css');
require('codemirror/mode/sql/sql');

var Elm = require('./elm/Main.elm');
require('./css/style.css');

// Set application flags
var flags = {
  hostname: window.location.hostname,
  protocol: window.location.protocol
};

// Run the application
var app = Elm.Main.fullscreen(flags);

// Set application ports
app.ports.initCodeEditor.subscribe(createCodeEditor);

function createCodeEditor(value) {
  requestAnimationFrame(function () {
    var element = document.querySelector('#code-editor');
    
    if (element) {
      var codeEditor = new CodeMirror(element, { 
        lineNumbers: true,
        mode: 'text/x-sql',
        value: value
      });
      
      codeEditor.on('changes', function (doc) {
        app.ports.codeChange.send(doc.getValue());
      });
    }
  });
}