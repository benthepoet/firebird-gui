// Import modules
var Elm = require('./Main.elm');

// Set application flags
var flags = {
  hostname: window.location.hostname,
  protocol: window.location.protocol
};

// Run the application
var app = Elm.Main.fullscreen(flags);