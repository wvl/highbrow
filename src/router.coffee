Backbone = require 'backbone'
_        = require 'underscore'

class Context
  constructor: (@path, @state={}, @root) ->
    @params = []
    @canonicalPath = @path
    @state.path = @path


class Route
  constructor: (@path, fns...) ->
    @keys = []
    @fns = fns
    @regexp = @pathtoRegexp(@path)

  dispatch: (ctx, callback) ->
    i = 0
    next = (err,result) =>
      return callback(err,result) if err or i==@fns.length

      fn = @fns[i++]
      if fn.length >= 2
        fn.call(ctx.root, ctx, next)
      else
        next(null, fn.call(ctx.root, ctx))

    next()

  # Check if this route matches `path`.
  # If it does, populate `params`.
  match: (path, params=[]) ->
    return true if path==@path

    qsIndex = path.indexOf('?')
    pathname = if ~qsIndex then path.slice(0, qsIndex) else path
    match = this.regexp.exec(pathname)

    return false unless match


    for m,i in match[1..]
      val = if typeof(m)=='string' then decodeURIComponent(m) else m
      key = @keys[i]
      if key
        params[key.name] = val
      else
        params.push(val)

    params


  pathtoRegexp: (p) ->
    return p if p instanceof RegExp
    p = "(#{p.join('|')})" if p instanceof Array
    p += '/?'
    p = p.replace(/\/\(/g, '(?:/')
    p = p.replace(/\+/g, '__plus__')
    p = p.replace /(\/)?(\.)?:(\w+)(?:(\(.*?\)))?(\?)?/g, (ign, slash, format, key, capture, optional) =>
      @keys.push({ name: key, optional: !! optional })
      slash = slash || ''
      result = if optional then "" else slash
      result += '(?:'
      result += if optional then slash else ''
      result += format || ''
      result += (capture || (format && '([^/.]+?)' || '([^/]+?)')) 
      result += ')' + (optional || '')
      result
    p = p.replace(/([\/.])/g, '\\$1')
    p = p.replace(/__plus__/g, '(.+)')
    p = p.replace(/\*/g, '(.*)')
    return new RegExp('^' + p + '$', 'i')


class Router
  @canNavigateAway = -> true

  constructor: (@base='', fns...) ->
    @running = false
    @routes = []
    @routers = {}
    @baseRoute = new Route(@base+'/*', fns...)

  match: (path, params) ->
    p = if path.slice(path.length-1)=='/' then path else path+'/'
    @baseRoute.match(p,params)

  page: (path, fns...) ->
    @routes.push new Route(@base+path, fns...)
    @

  show: (path, state, callback) ->
    if _.isFunction(state)
      callback = state
      state = {}


    @dispatch(new Context(path, state, @), callback)

  dispatch: (ctx, callback) ->
    @trigger 'start', ctx

    finish = (err, result) =>
      if err
        @trigger 'error', err, ctx, result
      else
        @trigger 'show', ctx, result
      callback.call(ctx.root,err,result,ctx) if callback

    @baseRoute.dispatch ctx, (err) =>
      return finish(err) if err

      # Find a match from this router first
      route = _.find @routes, (r) -> r.match(ctx.path, ctx.params)

      return route.dispatch ctx, finish if route

      router = _.find @routers, (router,base) ->
        router.match(ctx.path, ctx.params)

      return router.dispatch ctx, finish if router

      return @trigger('unhandled', ctx)


  start: (callback) ->
    return if @running
    @running = true
    @install()
    @replace(location.pathname+location.search, null, true, callback)

  stop: ->

  # Replace `path` with optional `state` object
  replace: (path, state, init, callback) ->
    ctx = new Context(path, state, @)
    ctx.replace = true
    ctx.init = init
    @dispatch ctx, callback

  mount: (base, fns...) ->
    @routers[@base+base] = new Router(@base+base, fns...)

  install: ->
    @on 'show', (ctx) ->
      if ctx.replace
        # console.log "replacestate: ", ctx.state, ctx.canonicalPath
        history.replaceState ctx.state, '', ctx.canonicalPath
      else
        # console.log "pushstate: ", ctx.state, ctx.canonicalPath
        history.pushState ctx.state, '', ctx.canonicalPath

    onpopstate = (e) =>
      @replace(e.state.path, e.state) if e.state

    onclick = (e) =>
      # console.log "router: onclick", e
      return if e.defaultPrevented
      el = e.target
      el = el.parentNode while el and 'A' != el.nodeName
      return if !el or 'A' != el.nodeName

      if !$(el).data('default') and !Router.canNavigateAway(el.href)
        return e.preventDefault()

      href = el.href
      path = el.pathname + el.search
      return if el.hash or !sameOrigin(href)

      e.preventDefault()
      @show path

    sameOrigin = (href) ->
      origin = location.protocol + '//' + location.hostname
      origin += ':' + location.port if location.port
      0 == href.indexOf(origin)

    addEventListener 'popstate', onpopstate, false
    addEventListener 'click', onclick, false

_.extend(Router.prototype, Backbone.Events)

module.exports = Router

