Backbone = require 'backbone'
_ = require 'underscore'
nct      = require 'nct'
require 'model_binder' if typeof window != 'undefined'

# A single item view implementation that contains code for rendering
# and calling several methods on extended views, such as `onRender`.
class ItemView extends Backbone.View
  constructor:  ->
    super
    @template ?= @options.template
    @namespace = @options.namespace if @options.namespace
    @namespace ?= @constructor.namespace
    @workflow ?= @options.workflow || {}
    @binder = new Backbone.ModelBinder() if browser and @model
    unless @template
      name = _.underscored(@constructor.name)
      @template = if @namespace then @namespace + '/' + name else name

  id: ->
    id = 'view-'+_.underscored(@constructor.name)
    id = id+'-'+@model.id if @model and @model.id
    id

  delegateEvents: (events) ->
    return unless browser
    super

  # override to specify title,subtitle,subnav
  view: {}

  data: ->
    return {} unless @model
    viewModel = @viewModel || ItemView.viewModels[@model.constructor.name]
    if viewModel then new viewModel(@model, @error) else @model

  context: ->
    viewdata = if _.isFunction(@view) then @view() else @view
    ctx = new nct.Context(_.extend({@workflow}, viewdata))
    ctx.push(@data())

  # Ensure that the View has a DOM element to render into.
  # If `this.el` is a string, pass it through `$()`, take the first
  # matching element, and re-assign it to `el`. Otherwise, create
  # an element from the `id`, `className` and `tagName` properties.
  _ensureElement: ->
    return @setElement(@el, false) if @el
    if @id and browser
      el = $('#'+ if _.isFunction(@id) then @id() else @id)
      return @setElement(el, false) if el.length and el.data('ssr')
    attrs = _.extend({}, @attributes)
    attrs.id = @id if @id
    attrs.id = @id() if @id and _.isFunction(@id)
    attrs['class'] = @className if @className
    @setElement @make(@tagName, attrs), false

  #   var el = this.make('li', {'class': 'row'}, this.model.escape('title'));
  make: (tagName, attributes, content) ->
    el = if browser then document.createElement(tagName) else Backbone.$("<"+tagName+"></"+tagName+">")
    Backbone.$(el).attr(attributes) if attributes
    Backbone.$(el).html(content) if content != null
    el

  renderTemplate:  ->
    return unless @template
    if browser and @$el.data('ssr')
      console.log "skipping render", @template
      @$el.data('ssr', false)
    else
      @$el.attr('data-ssr', true) unless browser
      @$el.html nct.render(@template, @context())
      console.log "rendered", @$el, @template if browser

  # Render the view with nct templates
  # You can override this in your view definition.
  render: ->
    @renderTemplate()
    @onRender() if browser
    @

  # rerender can be passed to event bindings, as it ignores arguments
  rerender: ->
    @$el.empty()
    @render()

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


  initBindings: ->
    if @bindings
      bindings = @convertBindings(@bindings)
      @binder.bind @model, @$el, bindings

  # Override for post render customization
  onRender: ->
    @initBindings() if @bindings

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
