admin = 
    get:
        index: (req, res) ->            
            if req.session.logged_in is true
                res.render('index')
            else
                res.render('login')
                
        logout: (req, res) ->
            delete req.session.username
            req.session.logged_in = false
            req.session.save()
            
            res.redirect('/admin')
            
        encoder: require('./encoder')
        
        torrents: require('./torrent')
                
    post:
        login: (req, res) ->
            if req.body.username is 'haxd' and req.body.password is 'm1001rl'
                req.session.username = 'haxd'
                req.session.logged_in = true
                req.session.error = false
                req.session.save()
            else
                req.session.error = 'Login failed!'
                
            res.redirect('/admin')

module.exports = (req, res) ->
    params = req.params
    
    switch params[0]
        when '/'
            res.redirect('/admin')
        when ''        
            admin.get.index req, res
        when '/login'
            admin.post.login req, res
        when '/logout'
            admin.get.logout req, res
        when '/encoder'
            admin.get.encoder.index req, res
        when '/encoder/jobs'
            admin.get.encoder.jobs req, res
        when '/encoder/jobs/create'
            admin.get.encoder.create req, res
        when '/torrents'
            admin.get.torrents.index req, res
        when '/torrents/get'
            admin.get.torrents.get req, res
        else
            console.log params
            res.send('OK')