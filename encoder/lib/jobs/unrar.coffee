spawn = require('child_process').spawn

class Unrar
    constructor: () ->
    
    do: (@job, @callback) ->
        console.log "Extracting %s to %s", @job.path, @job.dest
        
        if @job.dest.substring -1 isnt "/" then @job.dest += "/"
        
        unrar = spawn('unrar', ['e', '-y', @job.path, @job.dest])
        
        output = ''
        
        unrar.stdout.setEncoding 'utf8'
        unrar.stdout.on 'data', (data) ->
            output += data
            process.stdout.write data
            
        unrar.stderr.setEncoding 'utf8'
        unrar.stderr.on 'data', (data) ->
            output += data
            process.stdout.write data
            
        unrar.on 'exit', (code) =>
            console.log "Code: " + code
            @job.output = output
            @check output
            
            if code isnt 0
                @callback(output, null)
            else
                @callback(null, output, @job)
                
    check: (output) ->
        lines = output.split(/\n/g)
        @job.files = []
        
        for line in lines
            match = line.match /^[\.]+\s+([\w-.]+)/
            if match isnt null
                if @job.files.indexOf(@job.dest + match[1]) is -1
                    @job.files.push(@job.dest + match[1])
        
        
module.exports = Unrar