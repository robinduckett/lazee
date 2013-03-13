mkdirp = require('mkdirp')

path = require('path')
fs = require('fs')

Metalib = require('fluent-ffmpeg').Metadata
Timemark = require('../timemark')

class Encoder
    constructor: () ->
    
    do: (@job, @callback) =>        
        @currentFile = @job.encode_files[0]
        @basename = path.basename(@currentFile, path.extname(@currentFile))
        
        if @job.encode_files.length > 1
            @job.encode_files.shift()
            @job.queue.process @job.queue.getCopyJob @job
            @job.queue.process.update()
            
        @destination = path.join(__dirname, "..", "..", "..", "content", "video", @job.uuid)
        
        @getData()
        
        if !fs.existsSync(@destination)
            mkdirp(@destination, @encode)
        else
            @encode()
            
    getData: () ->        
        metaObject = new Metalib(@currentFile)
        
        metaObject.get((metadata, err) =>
            if !err
                @job.metadata = metadata
                @job.queue.addJob @job
        )
        
    progress: (progress) =>
        duration = if !@job.durationraw then @job.metadata.durationraw else @job.durationraw
        duration_seconds = new Timemark(duration).toSeconds()
        mark_seconds = new Timemark(progress.timemark).toSeconds()

        progress.percent = @percent = Math.ceil(mark_seconds / duration_seconds * 100)

        @job.progress = progress
        @job.queue.addJob @job

    saveFileCallback: (stdout, stderr) =>
        @job.done = true
        @job.stdout = stdout
        @job.stderr = stderr
        @job.encoded_file = path.join(@destination, @filename)
        @job.destination = @destination
        @job.filename = @filename
        @callback(null, null, @job)
            
module.exports = Encoder