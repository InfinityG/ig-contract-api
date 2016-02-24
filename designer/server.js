var express = require('express')
var serveStatic = require('serve-static')
var PORT = 8080;

var app = express()

app.use(serveStatic(__dirname + '/www'))
app.listen(PORT);
console.log('listening on port ' + PORT);