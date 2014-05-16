
class Collection extends highbrow.Backbone.Collection
  setParent: (@parent) ->

  @init: (context, models, options) ->
    options ?= {}
    options.context = context
    coll = new @(models, options)
    return coll

  constructor: (models, options) ->
    if options
      @context ?= options.context
      @parent ?= options.parent
      @url ?= options.url
    super

  add: (models, options={}) ->
    options.context = @context if @context
    highbrow.Backbone.Collection.prototype.add.call(this, models, options)

  url: ->
    throw new Error("urlRoot not specified for #{@}") unless @urlRoot
    _.result(@, 'urlRoot').replace(":parent", @parent?.url())

  fetchAndContinue: (next) ->
    this.fetch({
      success: -> next()
      error: (model,response) ->
        next(response)
    })

  close: ->
    @each (model) -> model.close()
    @unbindAll()
    @closed = true

Collection.prototype.sync = Model.prototype.sync
