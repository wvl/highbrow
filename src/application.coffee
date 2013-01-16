
#
# Highbrow Application Base class
#
#   * Extends the Router
#   * Has a builtin layout manager
#   * Has a builtin `store`, for caching data
#
# This is the simplest way to create a highbrow
# application.
#
# @param {$el} Jquery (or equivalent) DOM element 
#
class Application extends Router

  # The dom element should be passed into the constructor.
  constructor: (options={}, fns...) ->
    super options.base || '', fns...

    @$el = options.$el
    throw new Error("An '$el' must be specified") unless @$el

    @store = new Store()
    @_layout = null
    @_views = {}

  close: ->
    _.each @_views, (view) -> view?.close()
    @_views = {}

  # Switch layouts. This can be called for each
  # individual route. If this layout is currently
  # active, it will simply return.
  #
  # * @param layout   String: The layout name
  # * @param template String: Optional template to render
  # * @param main     String: This element will be used to
  #                         display the 'main' view into
  # * @param sections Object: An object of {name: view}
  #
  layout: (layout, template, main, sections={}) ->
    return if @_layout==layout
    @_layout = layout
    @_main = main
    if @$el.attr('data-ssr')=='true'
      @$el.data('ssr', false).attr('data-ssr','false')
    else
      @close()
      @$el.html nct.render template if template
      @$el.attr('data-ssr', 'true') if highbrow.server
    _.each sections, (fn, sel) => @display(fn.call(@), sel)

  # Displays a backbone view instance inside of the main region.
  # Handles calling the `render` method for you. Reads content
  # directly from the `el` attribute. Also calls an optional
  # `onShow` and `close` method on your view, just after showing
  # or just before closing the view, respectively.
  display: (view, selector) ->
    selector ?= @_main
    @_views[selector]?.close()
    @_views[selector] = view
    el = @$el.find(selector)
    view.render()
    if highbrow.browser
      if el.data('ssr')
        el.data('ssr', false)
      else
        el.html view.$el
    else
      el.html view.$el
      el.attr('data-ssr', 'true')
    view.onShow() if view.onShow and highbrow.browser
