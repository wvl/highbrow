_ = require 'underscore'

module.exports = base = {}

base.Model          = require './model'
base.Collection     = require './collection'
base.ViewModel      = require './view-model'
base.ItemView       = require './item-view'
formView            = require './form-view'
base.FormView       = formView.FormView
base.FormViewMixin  = formView.FormViewMixin
base.CollectionView = require './collection-view'
base.CompositeView  = require './composite-view'
base.RegionManager  = require './region-manager'
base.Application    = require './application'

base.Router         = require('./router')

base.setViewModels = (viewModels) ->
  base.ItemView.viewModels = viewModels

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

# _.extend(base.Controller.prototype, Backbone.Events)
# _.extend(base.Controller.prototype, base.BindTo)
_.extend(base.ItemView.prototype, base.BindTo)
# _.extend(base.CollectionView.prototype, base.BindTo)

