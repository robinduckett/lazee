module.exports =
    get:
        index: (req, res) ->
            if req.session.logged_in is true
                res.render('admin/index')
            else
                res.render('admin/login')

        logout: (req, res) ->
            delete req.session.username
            req.session.logged_in = false
            req.session.save()

            res.redirect('/admin')

    post:
        login: (req, res) ->
            if req.body.username is 'haxd' and req.body.password is 'm1001rl'
                req.session.username = 'haxd'
                req.session.logged_in = true
                req.session.administrator = true
                req.session.save()
            else
                req.session.error = 'Login failed!'

            res.redirect('/admin')