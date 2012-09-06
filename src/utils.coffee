_ = require 'underscore'
module.exports = base = {}

base.Backbone = require 'backbone'
base.nct = require 'nct'

# BindTo facilitates the binding and unbinding of events from objects that extend 
# `Backbone.Events`. It makes unbinding events, even with anonymous callback 
# functions, easy.
#
# Thanks to Johnny Oshika for this code.
# http://stackoverflow.com/questions/7567404/backbone-js-repopulate-or-recreate-the-view/7607853#7607853
base.BindTo =
  # Store the event binding in array so it can be unbound easily, at a later point in time.
  bindTo: (obj, eventName, callback, context) ->
    context = context || this
    obj.on(eventName, callback, context)
    @_BindToBindings ?= []
    @_BindToBindings.push({obj, eventName, callback, context})

  # Unbind all of the events that we have stored.
  unbindAll: ->
    _.each @_BindToBindings, (binding) -> binding.obj.off(binding.eventName, binding.callback)
    @_BindToBindings = []


_.underscored ?= (str) ->
  str.replace(/([a-z\d])([A-Z]+)/g, '$1_$2').replace(/\-|\s+/g, '_').toLowerCase()

base.browser = typeof window != 'undefined'
base.server = !base.browser

base.$ = undefined;

base.setDomLibrary = (lib) ->
  base.Backbone.setDomLibrary(lib)
  base.$ = lib

