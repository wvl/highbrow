Backbone = require('./utils').Backbone

class Collection extends Backbone.Collection
  setParent: (@parent) ->

  initialize: (options={}) ->
    @url = options.url if options.url
    super

  url: ->
    throw new Error("urlRoot not specified for #{@}") unless @urlRoot
    @urlRoot.replace(":parent", @parent?.url())

module.exports = Collection
