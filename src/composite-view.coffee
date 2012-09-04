
_ = require 'underscore'
ItemView = require './item-view'

class CompositeView extends ItemView
  constructor: ->
    super
    @_subViews = @subViews()
    console.log "Subviews: ", @_subViews if browser

  # override with sub views
  subViews: -> {}

  renderSubViews: (callback) ->
    if _.isArray(@_subViews)
      _.each @_subViews, (view, i) =>
        @$el.append(view.render().el) if view?.render
    else
      _.each @_subViews, (view, location) =>
        view.render()
        if browser and @$(location).data('ssr')
          console.log "skipping render", location
          @$(location).data('ssr', false)
        else
          @$(location).attr('data-ssr', true) unless browser
          @$(location).html view.$el

  # Render this views template first, then the child views
  render: (callback) ->
    @renderTemplate()
    @renderSubViews()
    @onRender()
    @

  onShow: ->
    _.each @_subViews, (view) -> view.onShow() if view?.onShow

  close: ->
    super
    _.each @_subViews, (view) -> view?.close()


module.exports = CompositeView
