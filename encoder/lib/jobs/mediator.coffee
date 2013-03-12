class Mediator
    constructor: () ->
    
    do: (@job, @callback) ->
        if @job.files
            for file in @job.files
                @scanAndQueue file
            
        if @job.path
            @scanAndQueue @job.path
            
    scanAndQueue: (file) ->
        console.log "scanning #{file}"

        extension = file.substring file.lastIndexOf(".")

        job = @job.queue.getCopyJob(@job)
                
        switch extension
            when ".avi", ".mkv", ".ogg", ".webm", ".flv"
                if !job.encode_files then job.encode_files = []
                
                if job.encode_files.indexOf(file) is -1
                    job.encode_files.push file

                job.done = false
                job.type = "encode"
            when ".rar"
                job.type = "unrar"
                job.path = file
                job.done = false
            else
                return

        delete job.id

        if job.done isnt true
            @job.queue.process job

        if @job.old_type
            @job.type = @job.old_type

        @job.done = true

        @callback(null, null, @job)
        
module.exports = Mediator