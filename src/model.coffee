
# Extend Backbone.Model with nested relationships. With this
# base class, you can compose your models together.
class Model extends Backbone.Model
  idAttribute: '_id'

  @init: (context, attributes, options) ->
    options ?= {}
    options.context = context
    model = new @(attributes, options)
    return model

  constructor: (attributes, options) ->
    if options
      @context ?= options.context
      @parent ?= options.parent
    @_firstSet = true
    super
    @name ?= @constructor.name

  # A node style accessor, that fetches the given id, 
  # calling the given callback on completion, with either
  # an error value, or the model.
  @find: (id, callback) ->
    model = new @()
    model.set(model.idAttribute, id)
    success = (m) ->
      callback(null, m)
    error = (m) ->
      callback(m)
    model.fetch {success, error}

  # Override this to describe the relationships that this
  # model has. This will be used to instantiate the sub
  # models or collections.
  #
  # This should be an object, ex:
  #
  #     relations: {
  #       user: models.User,
  #       settings: collection.Settings
  #     }
  #
  @relations: {}

  # As in 'relations', however, when this model is serialized
  # to the server, the embedded models/collections will
  # be included in the JSON.
  @embeddedRelations: {}

  destroy: ->
    @unbindAll()
    _.each @constructor.embedded_relations, (constructor, key) =>
      if this[key] instanceof Backbone.Collection
        _.each this[key].toArray(), (model) -> model.destroy()
      else
        this[key].destroy()
    super

  # Checks whether the model is valid or not.
  savable: ->
    return unless @validations
    required = _.filter (@validations.required || []), (f) =>
      @get(f)==undefined or @get(f)==''
    errors = _.map required, (field) -> {field, code: 'missing_field'}
    if errors.length then {message: "Validation Failed", errors} else null

  # Includes the relations in the output JSON
  # Any relations include just the id of the model
  # Any embedded relation will include the JSON of that model
  toJSON: (sub) ->
    obj = super()
    _.each @constructor.relations, (constructor, key) =>
      obj[key] = if @[key] instanceof Backbone.Model then @[key].id else undefined
    _.each @constructor.embedded_relations, (constructor, key) =>
      obj[key] = if @[key]?.toJSON then @[key].toJSON(true) else @[key]
    obj

  setParent: (@parent) ->

  initializeRelations: ->
    relations = _.extend({}, @constructor.relations, @constructor.embedded_relations)
    _.each relations, (constructor, key) =>
      if !@[key]
        throw new Error("Unknown relation: #{key}") unless constructor
        @[key] = new constructor(null, {@context, parent: @})


  # Pulls any relations out into standalone models/collections
  set: (attrs, options) ->
    relations = _.extend({}, @constructor.relations, @constructor.embedded_relations)
    _.each relations, (constructor, key) =>
      if attrs[key] instanceof Backbone.Collection
        @[key]?.close()
        @[key] = attrs[key]
        @[key].setParent(@) if @[key]?.setParent
        @[key].context = @context if @context
      else if attrs[key] instanceof Backbone.Model
        @[key]?.close()
        @[key] = attrs[key]
        @[key].setParent(@) if @[key]?.setParent
        @[key].context = @context if @context
      else
        if attrs[key]
          throw new Error("Unknown relation: #{key}") unless constructor
          @[key] ?= new constructor(null, {@context, parent: @})

          if _.isString(attrs[key])
            # support setting just the id, not the inflated model
            if @inflate
              @[key] = @inflate(attrs[key], key, constructor)
            else
              @[key] = attrs[key]
          else
            if @[key] instanceof Backbone.Collection
              @[key].reset(attrs[key], options) unless _.isString(attrs[key][0])
            else
              @[key].set(attrs[key], options)
        else if attrs[key] == null
          @[key]?.close()
          @[key] = null

      # @[key]?.on 'all', (args...) =>
      #   args[0] = "#{key}:#{args[0]}"
      #   @.trigger.apply(@, args)


      delete attrs[key] if attrs[key]

    if @_firstSet
      @initializeRelations()
      @_firstSet = null

    super(attrs, options)

  sync: (method, model, options) ->
    if highbrow.server
      options ?= {}
      options.context = @context || @parent?.context || {}
    else
      if method == 'read'
        queryCache = model?.context?.queryCache
        if (queryCache)
          url = _.result(model, 'url')
          result = queryCache[url]
          if (result and options.success)
            options.success(JSON.parse(result))
            delete queryCache[url]
            return
    Backbone.sync.call(this, method, model, options)

  fetchAndContinue: (next) ->
    this.fetch({
      success: -> next()
      error: (model,response) ->
        next(response)
    })

  close: ->
    return if @closed
    _.each @constructor.embedded_relations, (relation, key) =>
      @[key]?.close()
    _.each @constructor.relations, (relation, key) =>
      @[key]?.close()
    @unbindAll()
    @closed = true

