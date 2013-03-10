mkdirp = require('mkdirp')

path = require('path')
fs = require('fs')

Metalib = require('fluent-ffmpeg').Metadata

class Encoder
    constructor: () ->
    
    do: (@job, @callback) =>        
        @currentFile = @job.encode_files[0]
        @basename = path.basename(@currentFile, path.extname(@currentFile))
        
        if @job.encode_files.length > 1
            @job.encode_files.shift()
            @job.queue.process @job
            
        @destination = path.join(__dirname, "..", "..", "..", "content", "video", @basename)
        
        @getData()
        
        if !fs.existsSync(@destination)
            mkdirp(@destination, @encode)
        else
            @encode()
            
    getData: () ->        
        metaObject = new Metalib(@currentFile)
        
        metaObject.get((metadata, err) =>
            @job.metadata = metadata
            @job.queue.addJob @job
        )
        
    progress: (progress) =>
        if Math.ceil(progress.percent * 200) > @percent
            console.log "Converting #{@filename}: #{@percent}%"
            
        @percent = Math.ceil(progress.percent * 200)
        
        @job.progress = progress
        @job.queue.addJob @job
            
module.exports = Encoder