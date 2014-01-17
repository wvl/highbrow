class PaginatedCollection extends Collection
  constructor: (models, options={}) ->
    @query = options.query or {}
    @query.page = Number(@query.page) || 1
    @query.perPage = Number(@query.perPage) || @perPage || 10
    super

  parse: (resp) ->
    if (resp.total != undefined) and resp.models
      @page = Number(resp.page)
      @perPage = Number(resp.perPage)
      @total = Number(resp.total)
      return resp.models
    else
      result = Collection.prototype.parse.call(this, resp)
      @page = 1
      @perPage = Math.MAX_VALUE
      @total = result.length
      return result

  queryParams: (page) ->
    highbrow.querystring.stringify if page then _.extend({}. @query, {page}) else @query

  url: ->
    @urlRoot.replace(':parent', @parent?.url()) + '?' + @queryParams()

  pageInfo: ->
    page = @query.page
    perPage = @query.perPage

    info  = {@total, page, perPage, prev: false, next: false, prevUrl: '#', nextUrl: '#'}
    info.pages = Math.ceil(@total / perPage)

    max = Math.min(@total, page * perPage)

    info.range = [(page-1)*perPage+1,max]
    info.start = info.range[0]
    info.end = info.range[1]

    info.prev = page - 1 if page > 1
    info.prevUrl = '?'+@queryParams(info.prev) if info.prev
    info.next = page + 1 if page < info.pages
    info.nextUrl = '?'+@queryParams(info.next) if info.next

    info

  nextPage: ->
    return false unless @pageInfo().next
    @query.page += 1
    @fetch()

  previousPage: ->
    return false unless @pageInfo().prev
    @query.page -= 1
    @fetch()
