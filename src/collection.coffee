
class Collection extends highbrow.Backbone.Collection
  setParent: (@parent) ->

  @init: (context, models, options) ->
    options ?= {}
    options.context = context
    coll = new @(models, options)
    return coll

  owner: true,

  constructor: (models, options) ->
    @owner = options?.owner unless options?.owner == undefined
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

  _reset: ->
    if @owner
      @each (model) -> model.close()
    super

  close: ->
    return if @closed
    @unbindAll()
    @reset [], {silent: true}
    @closed = true

Collection.prototype.sync = Model.prototype.sync
