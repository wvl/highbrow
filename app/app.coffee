_ = require 'underscore'
backbone = require 'backbone'
highbrow = require 'highbrow'
highbrow.setDomLibrary require('jquery') if highbrow.browser
routes = require './routes'
module.exports = api = {}

if (typeof window != 'undefined')
  require './templates'
  window.browser = true
else
  global.browser = false

buildApp = ($) ->
  app = new highbrow.Application({$el: $('body')})
  app.page '/', routes.index
  app.page '', routes.index

  app.on 'show', (ctx, view) ->
    @display view, '#main' if view and view instanceof highbrow.ItemView

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
