#
# Transmission Control Class for Node.js
# @author Robin Duckett <rduckett@xumo.com>
#

require 'globals'

request = require 'request'
_ = require 'lodash'

EventEmitter = require('events').EventEmitter

class Control extends EventEmitter
    connect: (options) ->
        defaults =
            host: 'localhost'
            port: '9091'
            authRequired: false
            username: 'admin'
            password: 'password'
            interval: 2000

        options = _.extend defaults, options

        @url = 'http://' + options.host + ':' + options.port + '/transmission/rpc'
        @authRequired = options.authRequired
        @username = options.username
        @password = options.password

        @torrents = []

        @query 'torrent-get',
            fields: [ "id", "name", "status" ]
        , (err, res, body) =>
            if body and body.result is "success"
                @emit 'connected'
                @watchInterval = setInterval(=>
                    @watch()
                , options.interval)
            else
                @emit 'error', err

    watch: ->
        @query 'torrent-get',
            fields: ["id", "name", "isFinished", "isStalled", "status", "leftUntilDone", "rateDownload", "rateUpload", "totalSize", "doneDate"]
        , (err, res, body) =>
            if body and body.result is 'success'
                torrents = body.arguments.torrents
                names = _.pluck(torrents, 'name');

                if @torrents.length > 0
                    current_names = _.pluck(@torrents, 'name');

                    added = _.difference(names, current_names)
                    removed = _.difference(current_names, names)
                else
                    added = names
                    removed = []

                _.each added, (torrent_name) =>
                    torrent = _.find(torrents, (tname) => tname.name is torrent_name);
                    @emit 'added', torrent
                    @torrents.push torrent

                _.each removed, (torrent_name) =>

                    remove_index = -1

                    for torrent, index in @torrents
                        if torrent.name is torrent_name
                            remove_index = index
                            break

                    if remove_index > -1
                        torrent = @torrents[remove_index]
                        @emit 'removed', torrent
                        @torrents.splice remove_index, 1

                _.each @torrents, (old_torrent, index) =>
                    torrent = _.find(torrents, (tname) => tname.name is old_torrent.name);

                    if !old_torrent.equals torrent
                        @torrents[index] = torrent
                        @emit 'changed', torrent

            else
                console.error err
                clearInterval @watchInterval
                console.error 'Stopping watching due to previous errors'
                process.exit()


    query: (method, args, callback) ->
        data =
            method: method
            arguments: args

        headers =
            'Content-Type': 'application/json'
            'x-transmission-session-id': @sessionId

        if @authRequired
            headers.Authorization = 'Basic ' + new Buffer(@username + ':' + @password).toString 'base64'

        requestOptions =
            url: @url
            method: 'POST'
            body: JSON.stringify data
            headers: headers

        request requestOptions, (err, res, body) =>
            if err
                console.log "TorrentControl: " + err.toString()
            else
                if res.headers['x-transmission-session-id']
                    @sessionId = res.headers['x-transmission-session-id']

                switch res.statusCode
                    when 409
                        console.log 'Retrieving RPC Session ID'
                        @query method, args, callback
                    when 401 then throw new Error "Invalid username / password"
                    else
                        try
                            jsonBody = JSON.parse body
                        catch error
                            callback.call @, error

                        if jsonBody isnt undefined
                            callback.call @, err, res, jsonBody
                        else
                            callback.call @, "unable to parse JSON"


module.exports = new Control