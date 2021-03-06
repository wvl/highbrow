highbrow.installSync = (app, defaultRequest={}) ->
  baseRequest =
    connection:
      encrypted: false
    headers:
      cookie: null
    socket:
      destroy: ->

  methodMap =
    create: 'post'
    update: 'put'
    delete: 'delete'
    read:   'get'

  highbrow.Backbone.sync = (method, model, options) ->
    # console.log("Sync called", method, model, options)
    url = options.url
    url ?= if _.isFunction(model.url) then model.url() else model.url

    req = _.extend {}, baseRequest, defaultRequest, {
      method: methodMap[method]
      url: (if url.slice(0,2)=='//' then 'http:'+url else url)
    }, (options.context|| {})

    # Ensure that we have the appropriate request data.
    if (!options.data && model && (method == 'create' || method == 'update'))
      req.body = model.toJSON()
      
    req.query = _.extend {}, req.query, options.data, model.query

    res =
      send: (status, json) ->
        if !_.isNumber(status)
          json = status
          status = 200
        if status==200
          # Mongoose decorates the object returned with all sorts of extra
          # attributes that mess up backbone. Shortcut to strip that crap out.
          resultString = if typeof json == 'string' then json else JSON.stringify(json)
          if model.context
            model.context.queryCache ?= {}
            model.context.queryCache[url] = resultString

          options.success(JSON.parse(resultString))
        else
          options.error({status, responseText: JSON.stringify(json)})
        res.emit('header')
      end: (msg) ->
        options.error({status: 500, responseText: msg})
        res.emit('header')
      setHeader: ->

    # Call the matching route with middleware
    app.handle req, res
