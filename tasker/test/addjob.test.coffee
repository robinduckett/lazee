{chai, sinon} = require './depends'

Tasker = require '../src/Tasker'

describe 'Tasker', ->
  tasker = null

  beforeEach ->
    tasker = new Tasker

  describe '#addJob', ->
    it 'should have tests', ->
      {}.should.be.an.object

    it 'should add jobs to the internal object', ->
      tasker.addJob
        uuid: 'test'

      tasker.jobs.test.uuid.should.equal 'test'
      tasker.jobs.test.uuid.should.not.equal 'test1'

    it 'should add jobs to the subjobs if the uuid exists', ->
      tasker.addJob
        name: 'parent'
        uuid: 'uuid1'

      tasker.addJob
        name: 'parent'
        uuid: 'uuid2'

      tasker.addJob
        name: 'child'
        uuid: 'uuid1'

      tasker.jobs.uuid1.name.should.equal 'parent'
      tasker.jobs.uuid2.name.should.equal 'parent'
      tasker.jobs.uuid1.subjobs.should.not.be.an('undefined')
      tasker.jobs.uuid1.subjobs[0].name.should.equal 'child'