control = require('../control')
transmission = require("#{__dirname}/../../../config/transmission.json")
        
try
    control.connect transmission
catch e
    util.log e
        
control.on 'connected', () ->
    util.log "Connected to Transmission"

module.exports =
    get:
        index: (req, res) ->
            res.render 'admin/torrent',
                transmission: "/transmission/web/"
                torrents: control.torrents

        get: (req, res) ->
            res.json control.torrents