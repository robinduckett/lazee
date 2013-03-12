Ffmpeg = require('fluent-ffmpeg')
mkdirp = require('mkdirp')

path = require('path')
fs = require('fs')

class Encode
    constructor: () ->
    
    do: (@job, @callback) ->
        
        h264_job = @job.queue.getJob(@job)
        webm_job = @job.queue.getJob(@job)
       
        delete h264_job.id
        delete webm_job.id
        
        h264_job.stdout = ''
        webm_job.stderr = ''
        
        h264_job.type = 'encode_h264'   
        @job.queue.process h264_job
       
        webm_job.type = 'encode_webm'
        @job.queue.process webm_job
        
        @job.done = true
        @callback(null, null, @job)
        
module.exports = Encode