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


#
# Using "Convention over Configuration" to lookup templates, using
# `underscored` versions of the view's name:
base.underscored = (str) ->
  str.replace(/([a-z\d])([A-Z]+)/g, '$1_$2').replace(/\-|\s+/g, '_').toLowerCase()
_.underscored ?=  base.underscored



#
# Accessible variables to determine what environment we're running in.
base.browser = typeof window != 'undefined'
base.server = !base.browser

base.$ = undefined;

# Use this function to set what Dom Library to use. This can be
# cheerio on the server, and jquery (or equivalent) on the client.
base.setDomLibrary = (lib) ->
  base.Backbone.setDomLibrary(lib)
  base.$ = lib

# Because highbrow uses "convention over configuration", we need
# a name associated with our views and models. The default extend
# implementation used from javascript with backbone does not give
# you this name. Therefore, this is a simple wrapper around
# backbone's extend that lets you set the name of the view/model.
#
# eg.
# var User = highbrow.extend('Model','User', {})
#
# This is not needed from coffeescript, where this is sufficient:
#
# class User extends highbrow.Model
#
base.extend = (cls,name,protoProps,classProps) ->
  throw new Error("Unknown base class "+cls) unless base[cls]
  newcls = base[cls].extend(protoProps, classProps)
  newcls::name = name
  newcls

