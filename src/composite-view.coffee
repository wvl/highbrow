
_ = require 'underscore'
ItemView = require './item-view'
utils    = require './utils'

# This view allows you to compose multiple
# views together, by setting the `subViews`
# attribute.
#
# The subViews attribute should be a function
# that returns either an array or an object
# of views.
# * If it is an array, the views will simply be
# appended.
# * If it is an object, the views will be
# inserted into the dom at the given selector.
class CompositeView extends ItemView
  constructor: ->
    super
    @_subViews = @subViews()

  # override with sub views. It should be
  # a function that returns an object:
  #  { '.class': new View({model: this.model}) }
  subViews: -> {}

  renderSubViews: (callback) ->
    if _.isArray(@_subViews)
      _.each @_subViews, (view, i) =>
        @$el.append(view.render().el) if view?.render
    else
      _.each @_subViews, (view, location) =>
        view.render()
        if utils.browser and @$(location).data('ssr')
          # console.log "skipping render", location
          @$(location).data('ssr', false)
        else
          @$(location).attr('data-ssr', 'true') unless utils.browser
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
