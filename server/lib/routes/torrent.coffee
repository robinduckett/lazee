control = require('../control')
transmission_config = require("#{__dirname}/../../../config/transmission.json")
        
try
    control.connect transmission_config
catch e
    console.log e
        
control.on 'connected', () ->
    console.log "Connected to Transmission"

module.exports =    
    index: (req, res) ->        
        res.render 'torrent',
            transmission: transmission_config.url
            torrents: control.torrents
            
    get: (req, res) ->
        res.json control.torrents