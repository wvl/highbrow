class RegionManager extends Backbone.Events
  constructor: (@$el, @options={}) ->
    throw new Error("An 'el' must be specified") unless @$el

  # Displays a backbone view instance inside of the region.
  # Handles calling the `render` method for you. Reads content
  # directly from the `el` attribute. Also calls an optional
  # `onShow` and `close` method on your view, just after showing
  # or just before closing the view, respectively.
  show: (view) ->
    # @trigger('close', @currentView)
    @currentView.close() if @currentView?.close
    @currentView = view
    view.render()
    if browser and @$el.data('ssr')
      @$el.data('ssr', false)
    else
      @$el.html view.$el
    view.onShow() if view.onShow and browser
    # @trigger('show', view)

  canNavigateAway: (href) ->
    return true unless @currentView['canNavigateAway']
    return true if @currentView.canNavigateAway()
    $('#modal').html nct.render('navigate_away', {href})
    $('#modal').modal()
    false

module.exports = RegionManager
