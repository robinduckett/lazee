async = require('async')
util = require('util')
nicetime = require('nicetime')

capitalize = (str) ->
  str.charAt(0).toUpperCase() + str.slice(1)

class Queue
    constructor: ->
        @queue = []
        @id = 0
        
        @watch = setInterval @update, 1000
        
    process: (job) ->    
        if !job.id
            job.id = @id++
                
        job.queue = @
        @queue.push(job)
        
    update: () =>
        if @queue.length > 0
            @do @queue.shift()
                
    do: (job) ->
        util.log util.format "Processing %s Job", job.type
        
        if job.done is true
            util.log "All tasks for Job #{job.id} complete"
            return
        
        try
            Task = require('./jobs/' + job.type)
            
            task = new Task();
            
            task.do job, @handleTask
        catch e
            util.error "Job error: " + e
            
    handleTask: (error, result, job) =>
        if error isnt null
            util.error "Job error:"
            console.log error.replace(/([\r\n]+)/g, "\n")
        else
            job.finished = new Date()
                    
            util.log util.format "Job %s complete:", capitalize(job.type)
            util.log util.format "  Job Id: %s", job.id
            util.log util.format "  Time Taken: %s", nicetime(new Date(job.created).getTime() / 1000, new Date(job.finished).getTime() / 1000)        
                
            if job.done is true
                util.log "All tasks for Job #{job.id} complete"
            else                    
                job.type = "mediator"
                @process job
                
                
        
module.exports = new Queue()