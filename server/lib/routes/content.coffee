module.exports =
  get:
    index: (req, res) ->
      collections = req.app.get('collections')

      collections.jobs.find().toArray (err, results) ->
        console.log results

        res.render 'admin/content',
          jobs: results