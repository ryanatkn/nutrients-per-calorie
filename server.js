var express = require('express');

var server = express();

server.configure(function() {
  server.use(express.static(__dirname)); // self serving server at your service!
});

server.listen(1337);

console.log("Serving food at localhost:1337");