_ = require 'underscore'
utils    = require './utils'
nct      = utils.nct
Backbone = utils.Backbone
require 'model_binder' if utils.browser

# A single item view implementation that contains code for rendering
# and calling several methods on extended views, such as `onRender`.
class ItemView extends Backbone.View

  # In addition to the standard keys that can be passed to normal
  # Backbone views, this view class also takes the following keys:
  #
  # template: The name of the template to be used for this view.
  #   Normally, this template name is derived from the name of the
  #   view, converted into lowercase and underscores. So, if the name
  #   of the view is "UserSignup", the template name that will be used
  #   is "user_signup".
  #
  _configure:  ->
    super
    @name ?= @options.name || @constructor.name
    @template ?= @options.template
    @namespace = @options.namespace if @options.namespace
    @namespace ?= @constructor.namespace
    @workflow ?= @options.workflow || {}
    if !@template and @template!=false
      throw new Error("Unknown template. Please provide a name or template") unless @name
      template = _.underscored(@name)
      @template = if @namespace then @namespace + '/' + template else template

  constructor: ->
    super
    @binder = new Backbone.ModelBinder() if utils.browser and @model

  #
  # When rendering a collection
  id: ->
    id = 'view-'+(@template || _.underscored(@name || ''))
    id = id+'-'+@model.id if @model and @model.id
    id


  delegateEvents: (events) ->
    return if utils.server
    super

  # override to specify title,subtitle,subnav
  view: {}

  data: ->
    return {} unless @model
    viewModel = @viewModel || ItemView.viewModels[@model.name]
    if viewModel then new viewModel(@model, @error) else @model

  context: ->
    viewdata = if _.isFunction(@view) then @view() else @view
    ctx = new nct.Context(_.extend({@workflow}, viewdata))
    ctx.push(@data())

  # Ensure that the View has a DOM element to render into.
  # If `this.el` is a string, pass it through `$()`, take the first
  # matching element, and re-assign it to `el`. Otherwise, create
  # an element from the `id`, `className` and `tagName` properties.
  #
  # Changes from Backbone default:
  # * If we are in the browser, check to see if the view has
  #   already been rendered (by the server).
  _ensureElement: ->
    return @setElement(@el, false) if @el
    if @id and utils.browser
      el = $('#'+ if _.isFunction(@id) then @id() else @id)
      return @setElement(el, false) if el.length and el.data('ssr')
    attrs = _.extend({}, @attributes)
    attrs.id = @id if @id
    attrs.id = @id() if @id and _.isFunction(@id)
    attrs['class'] = @className if @className
    @setElement @make(@tagName, attrs), false

  #   var el = this.make('li', {'class': 'row'}, this.model.escape('title'));
  # Changes from Backbone:
  #  Use highbrow.$ to create elements on the server
  make: (tagName, attributes, content) ->
    el = if utils.browser then document.createElement(tagName) else utils.$("<"+tagName+"></"+tagName+">")
    utils.$(el).attr(attributes) if attributes
    utils.$(el).html(content) if content != null
    el

  # Render template will render the associated template.
  # * We do not rerender the template, if the view has already been
  #   rendered on the server.
  renderTemplate:  ->
    return unless @template
    if utils.browser and @$el.data('ssr')
      # console.log "skipping render", @template
      @$el.data('ssr', false)
    else
      @$el.attr('data-ssr', 'true') unless utils.browser
      @$el.html nct.render(@template, @context())
      # console.log "rendered", @$el, @template if utils.browser

  # Render the view with nct templates
  # You can override this in your view definition.
  render: ->
    @renderTemplate()
    @onRender() if utils.browser
    @

  # empty the associated element, and render
  rerender: ->
    @$el.empty()
    @render()

  # A helper function to simplify using Backbone ModelBinder
  convertBindings: (bindings) ->
    result = {}
    _.each bindings, (val,key) ->
      if _.isString(val)
        result[key] = val
      else
        result[key] = {selector: val[0]}
        if member=val[1]
          result[key].converter = (dir,val,attr,model) ->
            if dir=='ModelToView'
              model[member]()
            else
              model[member](val)
    result


  # Associated bindings.
  # TODO: Explain the format of this.bindings
  initBindings: ->
    if @bindings
      bindings = @convertBindings(@bindings)
      @binder.bind @model, @$el, bindings

  # Override for post render customization
  onRender: ->
    @initBindings() if @bindings

  # Override for custom code on dom show
  onShow: ->

  # Override for custom close code
  onClose: ->

  # Default `close` implementation, for removing a view from the
  # DOM and unbinding it. Region managers will call this method
  # for you. You can specify an `onClose` method in your view to
  # add custom code that is called after the view is closed.
  close: ->
    @unbindAll() # bindto events
    @unbind()    # custom view events
    if @attached then @$el.empty() else @remove()    # remove el from DOM (and DOM events)
    @onClose()   # custom cleanup code


module.exports = ItemView
