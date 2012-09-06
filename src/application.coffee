
_ = require 'underscore'
utils = require './utils'
Router = require './router'
# LayoutManager = require './layout-manager'
Store = require './store'
nct = require 'nct'

module.exports = class Application extends Router
  constructor: (options={}) ->
    super options.base || ''

    @$el = options.$el
    throw new Error("An '$el' must be specified") unless @$el

    @store = new Store()
    @_layout = null
    @_views = {}

  close: ->
    _.each @_views, (view) -> view?.close()
    @_views = {}

  layout: (layout, template, main, sections={}) ->
    return if @_layout==layout
    @_layout = layout
    @_main = main
    if @$el.attr('data-ssr')=='true'
      @$el.data('ssr', false).attr('data-ssr','false')
    else
      @close()
      @$el.html nct.render template
    _.each sections, (fn, sel) => @display(fn.call(@), sel)

  # Displays a backbone view instance inside of the main region.
  # Handles calling the `render` method for you. Reads content
  # directly from the `el` attribute. Also calls an optional
  # `onShow` and `close` method on your view, just after showing
  # or just before closing the view, respectively.
  display: (view, selector) ->
    selector ?= @_main
    # @trigger('close', @currentView)
    @_views[selector]?.close()
    @_views[selector] = view
    el = @$el.find(selector)
    view.render()
    if utils.browser
      if el.data('ssr')
        el.data('ssr', false)
      else
        el.html view.$el
    else
      el.html view.$el
      el.attr('data-ssr', 'true')
    view.onShow() if view.onShow and utils.browser
    # @trigger('show', view)

