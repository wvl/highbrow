# BindTo facilitates the binding and unbinding of events from objects that extend 
# `Backbone.Events`. It makes unbinding events, even with anonymous callback 
# functions, easy.
#
# Thanks to Johnny Oshika for this code.
# http://stackoverflow.com/questions/7567404/backbone-js-repopulate-or-recreate-the-view/7607853#7607853
highbrow.BindTo =
  # Store the event binding in array so it can be unbound easily, at a later point in time.
  bindTo: (obj, eventName, callback, context) ->
    context = context || this
    obj.on(eventName, callback, context)
    @_BindToBindings ?= []
    @_BindToBindings.push({obj, eventName, callback, context})

  # Unbind all of the events that we have stored.
  unbindAll: ->
    _.each @_BindToBindings, (binding) -> binding.obj.off(binding.eventName, binding.callback, binding.context)
    @_BindToBindings = []


#
# Using "Convention over Configuration" to lookup templates, using
# `underscored` versions of the view's name:
highbrow.underscored = (str) ->
  str.replace(/([a-z\d])([A-Z]+)/g, '$1_$2').replace(/\-|\s+/g, '_').toLowerCase()
_.underscored ?=  highbrow.underscored

#
# Accessible variables to determine what environment we're running in.
highbrow.browser = typeof window != 'undefined'
highbrow.server = !highbrow.browser

# Use this function to set what Dom Library to use. This can be
# cheerio on the server, and jquery (or equivalent) on the client.
highbrow.setDomLibrary = (lib) ->
  if highbrow.Backbone.setDomLibrary
    highbrow.Backbone.setDomLibrary(lib)
  else
    highbrow.Backbone.$ = lib
  highbrow.$ = lib

# possible multiple versions of highbrow need to reference the same
# dom library. If that's the case, set the global `highbrowDomLibary`
if typeof highbrowDomLibrary != 'undefined'
  highbrow.setDomLibrary(highbrowDomLibrary)

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
highbrow.extend = (cls,name,protoProps,classProps) ->
  if typeof cls == 'string'
    throw new Error("Unknown highbrow class "+cls) unless highbrow[cls]
    newcls = highbrow[cls].extend(protoProps, classProps)
  else
    newcls = cls.extend(protoProps, classProps)
  newcls::name = name
  newcls

