class Mediator
    constructor: () ->
    
    do: (@job, @callback) ->
        if @job.files
            for file in @job.files
                @scanAndQueue file
            return
            
        if @job.path
            @scanAndQueue @job.path
            
    scanAndQueue: (file) ->
        extension = file.substring file.lastIndexOf(".")
                
        switch extension
            when ".avi", ".mkv", ".ogg", ".webm", ".flv"
                if !@job.encode_files then @job.encode_files = []
                
                if @job.encode_files.indexOf(file) is -1
                    @job.encode_files.push file
                    
                @job.type = "encode"
            when ".rar"
                @job.type = "unrar"
            else
                @job.done = true
                
        @job.queue.process @job
        
module.exports = Mediator