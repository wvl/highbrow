_ = require 'underscore'
backbone = require 'backbone'
backbone.$ ?= require 'jquery'
highbrow = require 'highbrow'
routes = require './routes'
module.exports = api = {}

if (typeof window != 'undefined')
  require './templates'
  window.browser = true
else
  global.browser = false

buildApp = ($) ->
  app = new highbrow.Application({$el: $('#main')})
  app.page '/', routes.index
  app.page '', routes.index

  app.on 'show', (ctx, view) ->
    console.log "show: ", view
    @display view if view and view instanceof highbrow.ItemView

  app

api.init = ->
  app = buildApp $
  console.log "start: ", app
  app.start()

api.render = ($, callback) ->
  app = buildApp $
  timeout = setTimeout (->
    calllback(new Error("page show timeout"))
  ), 2000
  cb = (args...) ->
    app.$el.attr('data-ssr', true)
    clearTimeout timeout
    callback(args...)

  app.show route, cb
