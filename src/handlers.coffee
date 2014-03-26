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
    timeout = setTimeout (->
      options.error("Server Backbone.sync timeout")
    ), 1000

    url = options.url
    url ?= if _.isFunction(model.url) then model.url() else model.url

    if url.slice(0,2)=='//'
      url = 'http:'+url

    req = _.extend {}, baseRequest, defaultRequest, {
      method: methodMap[method]
      url: url
    }, (options.context|| {})

    # Ensure that we have the appropriate request data.
    if (!options.data && model && (method == 'create' || method == 'update'))
      req.body = model.toJSON()
      
    req.query = _.extend {}, req.query, options.data, model.query

    res =
      send: (status, json) ->
        clearTimeout timeout
        if !_.isNumber(status)
          json = status
          status = 200
        if status==200
          if typeof json == 'string'
            options.success(JSON.parse(json))
          else
            # Mongoose decorates the object returned with all sorts of extra
            # attributes that mess up backbone. Shortcut to strip that crap out.
            options.success(JSON.parse(JSON.stringify(json)))
        else
          options.error({status, responseText: JSON.stringify(json)})
      end: (msg) ->
        options.error({status: 500, responseText: msg})
      setHeader: ->

    # Call the matching route with middleware
    app.handle req, res
