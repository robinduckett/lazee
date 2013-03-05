restify = require('restify')
connect = require('connect')
control = require('control')

control.connect
    authRequired: true

server = restify.createServer()

server.use connect.logger('tiny')
server.use restify.acceptParser(server.acceptable)
server.use restify.queryParser()
server.use restify.bodyParser()

server.get('/torrents', (req, res, next) ->
    res.contentType = 'text'
    res.send(JSON.stringify(control.torrents, null, 2))
)

control.on("connect", ->
    server.listen(8080, () ->
        console.log("Restify listening")
    )
)