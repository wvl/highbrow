
utils = require './utils'
_     = require 'underscore'

exports.installSync = (app, defaultRequest={}) ->
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

  utils.Backbone.sync = (method, model, options) ->
    # console.log("Sync called", method, model, options)
    timeout = setTimeout (->
      options.error("Server Backbone.sync timeout")
    ), 1000

    url = options.url
    url ?= if _.isFunction(model.url) then model.url() else model.url
    # req = express.request
    # console.log('req: ', req)

    req = _.extend baseRequest, defaultRequest, {
      method: methodMap[method]
      url: url
    }

    # Ensure that we have the appropriate request data.
    if (!options.data && model && (method == 'create' || method == 'update'))
      req.body = model.toJSON()

    res =
      send: (status, json) ->
        clearTimeout timeout
        if !_.isNumber(status)
          json = status
          status = 200
        if status==200
          options.success(json)
        else
          options.error({status, responseText: JSON.stringify(json)})
      end: (msg) ->
        options.error({status: 500, responseText: msg})
      setHeader: ->

    # app.router req, res
    app.handle req, res
