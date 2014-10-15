var express    = require('express');
var livereload = require('connect-livereload');

var app = express();

app.use(livereload({port: 35729}))
app.use(express.static(__dirname)); // self serving app at your service!

app.listen(1337);

console.log("Serving food at localhost:1337");