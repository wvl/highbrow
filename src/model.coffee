
# Extend Backbone.Model with nested relationships. With this
# base class, you can compose your models together.
class Model extends Backbone.Model
  idAttribute: '_id'

  @init: (context, params...) ->
    model = new @(params...)
    model.context = context
    return model

  constructor: ->
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
      obj[key] = if @[key]?.get then @[key].get('_id') else @[key]
    _.each @constructor.embedded_relations, (constructor, key) =>
      obj[key] = if @[key]?.toJSON then @[key].toJSON(true) else @[key]
    delete obj._id unless sub
    obj

  setParent: (@parent) ->

  # Pulls any relations out into standalone models/collections
  set: (attrs, options) ->
    relations = _.extend({}, @constructor.relations, @constructor.embedded_relations)
    _.each relations, (constructor, key) =>
      if attrs[key] instanceof Backbone.Collection
        @[key] = attrs[key]
        @[key].setParent(@) if @[key]?.setParent
      else if attrs[key] instanceof Backbone.Model
        @[key] = attrs[key]
        @[key].setParent(@) if @[key]?.setParent
      else
        @[key] ?= new constructor()
        @[key].setParent(@) if @[key]?.setParent

        if attrs[key]
          if _.isString(attrs[key])
            # support setting just the id, not the inflated model
            @[key] = @inflate(attrs[key], key, constructor)
          else
            if @[key] instanceof Backbone.Collection
              @[key].reset(attrs[key], options) unless _.isString(attrs[key][0])
            else
              @[key].set(attrs[key], options)
        else if attrs[key] == null
          @[key] = null

      # @[key]?.on 'all', (args...) =>
      #   args[0] = "#{key}:#{args[0]}"
      #   @.trigger.apply(@, args)


      delete attrs[key] if attrs[key]

    super(attrs, options)

  sync: (method, model, options) ->
    if highbrow.server
      options ?= {}
      options.context = @context || {}
    Backbone.sync.call(this, method, model, options)

  fetchAndContinue: (next) ->
    this.fetch({
      success: -> next()
      error: (model,response) ->
        next(response)
    })
