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
            for own prop, value of job
                if prop isnt "queue"
                    if typeof @jobs["job" + job.id] is "undefined" then @jobs["job" + job.id] = {}
                    
                    @jobs["job" + job.id][prop] = value
        else
            util.error "Tried to add a job with no Id!"
            
    getJob: (job) ->
        retJob = @jobs["job" + job.id]

        if typeof retJob is "undefined"
            @addJob job
            retJob = @getJob job

        retJob

    getJobs: ->
        jobs = {}

        for own jobkey, jobvalue of @jobs
            copyjob = {}

            for own key, value of jobvalue
                copyjob[key] = value

            delete copyjob.queue

            jobs[jobkey] = copyjob

        jobs

    getCopyJob: (job) ->
        cjob = @getJob job
        delete cjob.queue

        rjob = {}
        for own key, value of cjob
            rjob[key] = value

        cjob.queue = @
        rjob
        
    process: (job) ->    
        if typeof job.id is "undefined"
            @id = @id + 1
            job.id = @id
                
        job.queue = @
        @queue.push(job)
        
    update: () =>
        if @queue.length > 0
            @do @queue.shift()
                
    do: (job) ->
        job.processing = true
        
        util.log util.format "Processing %s Job", job.type
        
        if job.done is true
            util.log "All tasks for Job #{job.id} complete"
            return
        
        try
            Task = require('./jobs/' + job.type)
            
            task = new Task();
            
            task.do job, @handleTask
        catch e
            job.error = e
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