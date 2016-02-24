var express = require('express')
var serveStatic = require('serve-static')
var PORT = 8080;

var app = express()

process.argv.forEach(function (val, index, array) {
  if (val.indexOf('port=') == 0)
  	PORT = parseInt(val.split('=')[1]);
});

app.use(serveStatic(__dirname + '/www'));

app.get('/', function(req, res){
  res.sendfile(__dirname + '/www/index.html');
});

app.listen(PORT);
console.log('listening on port ' + PORT);