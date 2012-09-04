Backbone = require 'backbone'
_ = require 'underscore'

module.exports = class Store
  setIn: (bucket, name, value) ->
    @[bucket] ?= {}
    @[bucket][name] = value
    @trigger 'setIn', bucket, name, value
    @trigger "set:#{bucket}:#{name}", value

  set: (name, value) ->
    @[name] = value
    @trigger 'set', name, value
    @trigger 'set:'+name, value

_.extend Store.prototype, Backbone.Events
