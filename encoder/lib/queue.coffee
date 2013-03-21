async = require('async')
util = require('util')
moment = require('moment')
_ = require('underscore')

mongo_config = require(__dirname + '/../../config/mongo.json')
Mongo = require('mongodb').Db
Server = require('mongodb').Server

mongo = new Mongo(mongo_config.database, new Server(mongo_config.host, 27017,
    auto_reconnect: true
    poolSize: 4
),
    w: 0
    native_parser: false
)

jobs_collection = null

mongo.open (err, db) ->
    if err
        util.log "Unable to open database"
        console.log err
    else
        util.log "Connected to mongo database"

        db.collection "jobs", (err, collection) ->
            if err
                util.log "Unable to open collection"
                console.log err
            else
                util.log "Opened jobs collection"
                jobs_collection = collection

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

    getJobsArray: ->
        jobs = []

        for own jobkey, jobvalue of @jobs
            copyjob = {}

            for own key, value of jobvalue
                copyjob[key] = value

            delete copyjob.queue

            copyjob.oldjobkey = jobkey

            jobs.push(copyjob)

        jobs

    getCopyJob: (job) ->
        cjob = @getJob job
        delete cjob.queue

        rjob = {}
        for own key, value of cjob
            rjob[key] = value

        cjob.queue = @
        rjob

    removeJobByUuid: (uuid) ->
        found = []

        for own key, value of @jobs
            if value.uuid is uuid
                found.push key

        for id in found
            delte @jobs[id]

        found.length

        
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

            job.created = new Date();
            
            task.do job, @handleTask
        catch e
            job.error = e
            util.error "Job error: " + e
            util.error e.stack
            
    handleTask: (error, result, job) =>
        @addJob job
        @getJob(job).hasError = false
        
        if error isnt null
            util.error "Job error:"
            console.log error.replace(/([\r\n]+)/g, "\n")
            @getJob(job).error = error
            @getJob(job).hasError = true
        else
            job.finished = new Date()

            duration = moment.duration(0+moment(new Date(job.finished)).diff(moment(new Date(job.created)))).humanize()
            job.duration = duration

            util.log util.format "Job %s:%s complete:", job.uuid, capitalize(job.type)
            util.log util.format "  Time Taken: %s", duration

            @addJob job

            jobs = @getJobsArray()

            doneJobs = _.where jobs,
                uuid: job.uuid
                done: true

            allJobs = _.where jobs,
                uuid: job.uuid

            if job.done is true
                if doneJobs.length is allJobs.length
                    started = doneJobs[0].created
                    finished = doneJobs[doneJobs.length - 1].finished

                    dbjobs = []

                    h264 = _.where jobs,
                        uuid: job.uuid
                        done: true
                        hasError: false
                        type: 'encode_h264'

                    webm = _.where jobs,
                        uuid: job.uuid
                        done: true
                        hasError: false
                        type: 'encode_webm'

                    dbjobs = h264.concat webm

                    copyjob =
                        jobs: dbjobs
                        uuid: job.uuid
                        name: job.name
                        created: new Date()
                        duration: moment.duration(0+moment(new Date(finished)).diff(moment(new Date(started)))).humanize()

                    if job.hasError
                        return

                    if dbjobs.length is 0
                        return

                    try
                        jobs_collection.insert copyjob, (err, result) =>
                            if err
                                util.log "Unable to save job to database"
                            else
                                util.log "Job saved successfully"
                                @removeJobByUuid copyjob.uuid
                    catch e
                        util.error e
                        util.log "Database Error"

                    util.log "All tasks for Job #{job.uuid} complete"
                    util.log util.format "  Total Time Taken: %s", duration
                
                
        
module.exports = new Queue()