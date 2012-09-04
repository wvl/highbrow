Backbone = require 'backbone'
_        = require 'underscore'


class Model extends Backbone.Model
  idAttribute: '_id'

  @find: (id, callback) ->
    model = new @()
    model.set(model.idAttribute, id)
    success = (m) ->
      callback(null, m)
    error = (m) ->
      callback(m)
    model.fetch {success, error}

  @relations: {}
  @embeddedRelations: {}

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
      else if attrs[key] instanceof Backbone.Model
        @[key] = attrs[key]
      else
        @[key] ?= new constructor()

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

      @[key].setParent(@) if @[key]?.setParent

      delete attrs[key] if attrs[key]

    super(attrs, options)

module.exports = Model
