Ffmpeg = require('fluent-ffmpeg')
mkdirp = require('mkdirp')

path = require('path')
fs = require('fs')

class Encode
    constructor: () ->
    
    do: (@job, @callback) ->        
       h264_job = JSON.parse(JSON.stringify(@job))
       webm_job = JSON.parse(JSON.stringify(@job))
       
       delete h264_job.id
       delete webm_job.id
       
       h264_job.type = 'encode_h264'   
       @job.queue.process h264_job
       
       webm_job.type = 'encode_webm'
       @job.queue.process webm_job
        
module.exports = Encode