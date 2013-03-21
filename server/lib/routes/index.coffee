_routes =
    admin:
        content: require('./content')
        encoder: require('./encoder')
        main: require('./main')
        torrents: require('./torrents')
        users: require('./users')
        index: require('./admin')

    ping: index: get: index: (req, res) ->
        res.send({ping: "pong!"})

    index: require('./frontend')

_login_check = (req, res) ->
    if req.session.logged_in isnt true
        return false

    if req.session.administrator isnt true
        return false

    return true

module.exports = (app) ->
    app.all /^.*/, (req, res, next) ->
        if req.session.error?
            if req.session.seen_error is true
                delete req.session.error
                req.session.seen_error = false
            else
                req.session.seen_error = true
                req.session.save()

        if req.url.indexOf("admin/") > -1 and req.url isnt "/admin/login" and req.url isnt "/admin/logout"
            if not _login_check req, res
                req.session.error = "You are not authorised."
                req.session.seen_error = false
                req.session.save()
                res.redirect "/admin"

                return

        next()


    for own key, value of _routes
        for own section, methods of value
            for own method, routes of methods
                for own route, func of routes
                    ukey = "/#{key}"
                    usection = "/#{section}"

                    if section is "index"
                        usection = ""

                    if key is "index"
                        ukey = "/"

                    if route is "index"
                        url = "#{ukey}#{usection}"
                    else
                        url = "#{ukey}#{usection}/#{route}"

                    util.log "Routing #{method}: #{url}"

                    app[method] url, func