views = require './views'
module.exports = api = {}

api.index = (ctx) ->
  console.log "index view"
  new views.Index()



