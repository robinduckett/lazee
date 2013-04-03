{chai, sinon} = require './depends'

Tasker = require '../src/Tasker'

describe 'Tasker', ->
  tasker = null

  beforeEach ->
    tasker = new Tasker

  describe '#watch', ->
    it 'should add jobs to the queue on watch', ->
      tasker.addJob
        name: 'job1'
        uuid: 'uuid1'

      tasker.watch()

      tasker.queue.length.should.equal 1
      tasker.jobs.uuid1.started.should.be.a('date')

    it 'should batch add jobs if the job has subjobs', ->
      tasker.addJob
        name: 'job1-parent'
        uuid: 'job1'

      tasker.addJob
        name: 'job1-child'
        uuid: 'job1'

      tasker.watch()

      tasker.queue.length.should.equal 2
      tasker.jobs.job1.subjobs.length.should.equal 1
      tasker.jobs.job1.started.should.be.a('date')
      tasker.jobs.job1.subjobs[0].started.should.be.a('date')

    it 'should not enqueue more jobs than the queue limit allows', ->
      tasker.addJob
        name: 'job1-parent'
        uuid: 'job1'

      tasker.addJob
        name: 'job1-child'
        uuid: 'job1'

      tasker.addJob
        name: 'job1-child'
        uuid: 'job1'

      tasker.addJob
        name: 'job1-child'
        uuid: 'job1'

      tasker.watch()

      tasker.queue.length.should.equal 3
      tasker.jobs.job1.subjobs[0].should.have.property 'started'
      tasker.jobs.job1.subjobs[1].should.have.property 'started'
      tasker.jobs.job1.subjobs[2].should.not.have.property 'started'

    it 'should not affect the queued jobs when being run a lot', ->
      tasker.addJob
        name: 'job1-parent'
        uuid: 'job1'

      tasker.addJob
        name: 'job1-child'
        uuid: 'job1'

      tasker.addJob
        name: 'job1-child'
        uuid: 'job1'

      tasker.addJob
        name: 'job1-child'
        uuid: 'job1'

      tasker.watch()
      tasker.watch()
      tasker.watch()
      tasker.watch()
      tasker.watch()
      tasker.watch()
      tasker.watch()
      tasker.watch()

      tasker.queue.length.should.equal 3
      tasker.queue[0].should.eql tasker.jobs.job1
      tasker.queue[1].should.eql tasker.jobs.job1.subjobs[0]
      tasker.queue[2].should.eql tasker.jobs.job1.subjobs[1]

      tasker.jobs.job1.subjobs[0].should.have.property 'started'
      tasker.jobs.job1.subjobs[1].should.have.property 'started'
      tasker.jobs.job1.subjobs[2].should.not.have.property 'started'
