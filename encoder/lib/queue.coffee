async = require('async')
util = require('util')
nicetime = require('nicetime')

class Queue
    constructor: ->
        @queue = []
        
        @watch = setInterval @update, 1000
        
    process: (job) ->
        @queue.push(job)
        
    update: () =>
        if @queue.length > 0
            @do @queue.shift()
                
    do: (job) ->
        util.log "Processing %s Job", job.type
        
        try
            Task = require('./jobs/' + job.type)
            
            task = new Task();
            
            task.do job, (error, result) =>
                if error isnt null
                    util.error "Job error: " + error
                else
                    job.finished = new Date()
                    
                    util.log "Job %s complete:", job.type
                    util.log "  Job Id: %s", job.id
                    util.log "  Time Taken: %s", nicetime(job.created.getTime() / 1000, job.finished.getTime() / 1000)        
        catch e
            util.error "Job error: " + e
                
                
        
module.exports = new Queue()