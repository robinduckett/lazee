async = require('async')
util = require('util')
moment = require('moment')

capitalize = (str) ->
  str.charAt(0).toUpperCase() + str.slice(1)

class Queue
    constructor: ->
        @jobs = {}
        @queue = []
        @id = 0
        
        @watch = setInterval @update, 1000
        
    addJob: (job) ->
        if job.id
            for prop, value of job
                if prop isnt "queue"
                    if typeof @jobs["job" + job.id] is "undefined" then @jobs["job" + job.id] = {}
                    
                    @jobs["job" + job.id][prop] = value
        else
            util.error "Tried to add a job with no Id!"
            
    getJob: (job) ->
        @jobs["job" + job.id]
        
    process: (job) ->    
        if !job.id
            @id = @id + 1
            job.id = @id
            
        @addJob job
                
        job.queue = @
        @queue.push(job)
        
    update: () =>
        if @queue.length > 0
            @do @queue.shift()
                
    do: (job) ->
        @getJob(job).processing = true
        
        util.log util.format "Processing %s Job", job.type
        
        if job.done is true
            util.log "All tasks for Job #{job.id} complete"
            return
        
        try
            Task = require('./jobs/' + job.type)
            
            task = new Task();
            
            task.do job, @handleTask
        catch e
            @getJob(job).error = e
            util.error "Job error: " + e
            util.error e.stack
            
    handleTask: (error, result, job) =>
        @addJob job
        
        if error isnt null
            util.error "Job error:"
            console.log error.replace(/([\r\n]+)/g, "\n")
            @getJob(job).error = error
        else
            job.finished = new Date()
            
            duration = moment.duration(0+moment(new Date(job.finished)).diff(moment(new Date(job.created)))).humanize();
                    
            util.log util.format "Job %s complete:", capitalize(job.type)
            util.log util.format "  Job Id: %s", job.id
            util.log util.format "  Time Taken: %s", duration
                
            if job.done is true
                util.log "All tasks for Job #{job.id} complete"
            else                    
                job.type = "mediator"
                @process job
                
                
        
module.exports = new Queue()