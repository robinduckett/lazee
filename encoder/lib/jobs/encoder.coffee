mkdirp = require('mkdirp')

path = require('path')
fs = require('fs')

class Encoder
    constructor: () ->
    
    do: (@job, @callback) ->        
        @currentFile = @job.encode_files[0]
        @basename = path.basename(@currentFile, path.extname(@currentFile))
        
        if @job.encode_files.length > 1
            @job.encode_files.shift()
            @job.queue.process @job
            
        @destination = path.join(__dirname, "..", "..","..", "content", "video", @basename)
        
        if !fs.exists(@destination)
            mkdirp(@destination, @encode)
        else
            @encode()
            
module.exports = Encoder