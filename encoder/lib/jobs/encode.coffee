Ffmpeg = require('fluent-ffmpeg')
mkdirp = require('mkdirp')

path = require('path')
fs = require('fs')

class Encode
    constructor: () ->
    
    do: (@job, @callback) ->

        delete @job.path

        encodeFormats = [
            "h264"
#            "webm"
        ]

        for format in encodeFormats
            job = @job.queue.getCopyJob(@job)

            delete job.id
            job.stdout = job.stderr = ''
            job.type = "encode_#{format}"

            @job.queue.process job
            @job.queue.update()
        
        @job.done = true
        @callback(null, null, @job)
        
module.exports = Encode