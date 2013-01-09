Collection = require './collection'
utils = require './utils'

class PaginatedCollection extends Collection
  initialize: (options={}) ->
    @page = options.page or 1
    @perPage ||= 10

  # fetch: (options={}) ->

  parse: (resp) ->
    @page = Number(resp.page)
    @perPage = Number(resp.perPage)
    @total = Number(resp.total)
    return resp.models

  queryParams: ->
    utils.querystring.stringify {@page,@perPage}

  url: ->
    @urlRoot.replace(':parent', @parent?.url()) + '?' + @queryParams()

  pageInfo: ->
    info  = {@total, @page, @perPage, prev: false, next: false}
    info.pages = Math.ceil(@total / @perPage)

    max = Math.min(@total, @page * @perPage)
    max = @total if @total == @pages*@perPage

    info.range = [(@page-1)*@perPage+1,max]
    info.start = info.range[0]
    info.end = info.range[1]

    info.prev = @page - 1 if @page > 1
    info.next = @page + 1 if @page < info.pages

    info

  nextPage: ->
    return false unless @pageInfo().next
    @page += 1
    @fetch()

  previousPage: ->
    return false unless @pageInfo().prev
    @page -= 1
    @fetch()

module.exports = PaginatedCollection
