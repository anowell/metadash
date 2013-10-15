var http = require('http'),
    httpProxy = require('http-proxy'),
    connect = require('connect'),
    sensu = require('./sensu-config.js')

var port = 8000
var router = {}
for (var i=0; i<sensu.servers.length; i++) {
  var server = sensu.servers[i]
  router['/' + server.key] = server.host + ':4567'
}

var options = {
  pathnameOnly: true,
  router: router
}

var proxyServer = httpProxy.createServer(options, connect.static(__dirname+"/dist"));
proxyServer.listen(port, function() {
  console.log("Listening on port " + port)
});
