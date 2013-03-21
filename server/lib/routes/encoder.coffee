module.exports =
    get:
        index: (req, res) ->
            encoder = req.app.get('encoder')

            encoder.getJobs (jobs) ->
                res.render 'admin/encoder',
                    jobs: jobs

        jobs: (req, res) ->
            encoder = req.app.get('encoder')

            encoder.getJobs (jobs) ->
                res.json jobs

    post:
        create: (req, res) ->
            uuid = require('uuid')

            encoder = req.app.get('encoder')
            path = require('path')
            tmp = path.join(__dirname, '..', '..', '..', 'tmp')

            uuid = uuid()

            encoder.process
                uuid: uuid
                name: req.body.name
                type: 'mediator'
                files: req.body.files
                dest: path.join(tmp, uuid, '/')
                created: new Date()

            res.json
                success: "true"

            return