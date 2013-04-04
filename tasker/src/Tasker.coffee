_ = require 'underscore'

module.exports = class Tasker
  constructor: (options) ->
    @jobs = {}
    @queue = []

    @queue_limit = options?.queue_limit or 3
    @watch_interval = options?.watch_interval or 5000

    setInterval =>
      @watch()
    , @watch_interval

  addJob: (job) ->
    if @jobs[job.uuid]
      if not @jobs[job.uuid].subjobs
        @jobs[job.uuid].subjobs = []
    
      job.subjob = true
      @jobs[job.uuid].subjobs.push job

    else
      @jobs[job.uuid] = job

  enqueue: (job) ->
    if @queue.length < @queue_limit and _.size(@jobs) > 0
      job.enqueued = true
      job.start()

      @queue.push job
    else
      job.enqueued = false

  watch: ->
    for uuid, job of @jobs
      @enqueue job

      if job.enqueued
        if job.subjobs
          for subjob in job.subjobs
            @enqueue subjob

            if not subjob.enqueued
              break
      else
        break