Backbone = require 'backbone'
_ = require 'underscore'

# This is an extremely simple class for in process
# state management. Rather than relying on global
# variables, store is available from the application,
# and accessible at ctx.store inside any router function.
#
# The store extends Backbone.Events, and can be listened
# on for event changes, and used as an application wide
# notification bus.
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
