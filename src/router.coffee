
# The highbrow router is heavily inspired by page.js:
# http://visionmedia.github.com/page.js/
#
# This version is also usable on the server (no dependency
# on document being defined). Multiple routers can be 
# nested, allowing an app to be composed of multiple 
# pieces and joined together.
#
# var app = new Router()
#
# app.page('/', middleware, handler);
# var dashboard = app.mount(
#   new Router('/dashboard', dashboard.middleware));
# dashboard.page('', dashboard.root);
# dashboard.page('new', dashboard.newPage);
#


#
# Context is the object that is passed to each
# route function. Intermediate data can be
# attached to the object as needed.
class Context
  constructor: (@path, @state={}, @root, @callback) ->
    @params = []
    @canonicalPath = @path
    i = @path.indexOf('?')
    @querystring = if ~i then @path.slice(i+1) else ''
    @path = @path.slice(0,i) if ~i
    @state.path = @canonicalPath

  query: (key) ->
    obj = highbrow.querystring.parse(@querystring)
    if key then obj[key] else obj


#
# The internal implementation of each page.
#
class Route
  constructor: (@path, fns...) ->
    @keys = []
    @fns = fns
    @regexp = @pathtoRegexp(@path)

  dispatch: (ctx, callback, fns=[]) ->
    i = 0
    fns = fns.concat(@fns)

    next = (err,result) =>
      return callback(err,result) if err or i==fns.length or ctx.finished

      fn = fns[i++]

      return callback(new Error("Unknown route function")) unless fn

      if fn.length >= 2
        try
          fn.call(ctx.root, ctx, next)
        catch err
          return callback(err)
      else
        try
          next(null, fn.call(ctx.root, ctx))
        catch err
          return callback(err)

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
    p = p.replace(/\*/g, '(.*)')
    return new RegExp('^' + p + '$', 'i')

  unload: (fns...) ->
    @unloadHandlers = fns

  close: (ctx, callback) ->
    return callback() unless @unloadHandlers
    i = 0
    next = (err) =>
      return callback(err) if err
      return callback() if i==@unloadHandlers.length

      fn = @unloadHandlers[i++]
      return callback(new Error("Unknown unload handler")) unless fn
      try
        fn.call(ctx.root, ctx, next)
      catch err
        ctx.root.trigger 'error', err, ctx
        return callback(err)

    next()


#
# This is the entry point to highbrow's router.
# Create a new instance of the router, and attach
# pages to it:
#
# router = new Router('/app')
class Router
  @canNavigateAway = -> true

  # The router can be mapped to a subpath, by
  # passing that in as the first parameter to the
  # constructor.
  #
  # Default routing functions can also be attached
  # to the router, that will be called when any
  # path on this router matches.
  constructor: (@base='', fns...) ->
    @running = false
    @routes = []
    @routers = {}
    @currentRoute = false
    @baseRoute = new Route(@base+'/*', fns...)
    @baseRouteDispatch = _.bind(@baseRoute.dispatch, @baseRoute)

  match: (path, params) ->
    p = if path.slice(path.length-1)=='/' then path else path+'/'
    @baseRoute.match(p,params)

  # Define a new page on the router.
  # The path can contain:
  # page('/user/:user', load, show) // parameters
  page: (path, fns...) ->
    route = new Route(@base+path, fns...)
    @routes.push route
    route

  browser: (path, fns...) ->
    fns.unshift (ctx,next) ->
      ctx.finished = highbrow.server
      next()
    @page path, fns...

  # Route to the given path, with an optional state and callback
  show: (path, state, callback) ->
    if _.isFunction(state)
      callback = state
      state = {}

    if state instanceof Context
      state.redirecting = true
      callback ?= state.callback
      state = {redirecting: true}

    ctx = new Context(path, state, @, callback)
    @dispatch(ctx, callback || ctx.callback)

  dispatch: (ctx, callback, fns=[]) ->
    @trigger 'start', ctx
    fns.push(@baseRouteDispatch)

    finish = (err, result) =>
      return if ctx.redirecting

      if err
        @trigger 'error', err, ctx, result
      else
        @trigger 'show', ctx, result

      @trigger 'page', ctx, result

      callback.call(ctx.root,err,result,ctx) if callback


    # Find a match from this router first
    route = _.find @routes, (r) -> r.match(ctx.path, ctx.params)

    if route
      if ctx.root.currentRoute
        ctx.root.currentRoute.route.close ctx.root.currentRoute.ctx, ->
          ctx.root.currentRoute = {route,ctx, path: route.path} # if highbrow.browser
          route.dispatch(ctx, finish, fns)
      else
        ctx.root.currentRoute = {route,ctx, path: route.path} # if highbrow.browser
        route.dispatch(ctx, finish, fns)
      return true
    else
      router = _.find @routers, (router,base) ->
        router.match(ctx.path, ctx.params)

      if router
        return router.dispatch ctx, finish, fns
      else
        ctx.root.trigger('unhandled', ctx)
        return false


  # When called from the browser, this will dispatch to the route
  # matching the browser's current location.
  #
  # An optional callback will be called when routing has finished
  start: (callback) ->
    return if @running
    @running = true
    @install()
    @replace(location.pathname+location.search, null, true, callback)

  stop: ->

  # Replace `path` with optional `state` object
  replace: (path, state, init, callback) ->
    ctx = new Context(path, state, @, callback)
    ctx.replace = true
    ctx.init = init
    @dispatch ctx, callback

  # Mount a new router at the given base. This lets you nest different
  # segments of your application.
  #
  # For example, you can mount an admin section, and ensure the user
  # is authenticated before following any of its pages:
  #
  # var admin = router.mount('/admin', ensureUserIsAdmin);
  # admin.page('', adminRoutes.rootPage);
  # admin.page('/dashboard', adminRoutes.dashboard);
  mount: (base, fns...) ->
    @routers[@base+base] = new Router(@base+base, fns...)

  # Install is called from start, and will install the
  # pushState,popState event handlers for the html5 history api.
  # It will also install an onclick handler that will intercept
  # any matching routes.
  install: ->
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
      return if el.hash or el.getAttribute('href')=='#' or !sameOrigin(href)

      return if e.altKey or e.ctrlKey or e.metaKey or e.shiftKey
      return if $(el).attr('target') == '_blank'

      e.preventDefault()
      @show path

    sameOrigin = (href) ->
      origin = location.protocol + '//' + location.hostname
      origin += ':' + location.port if location.port
      0 == href.indexOf(origin)

    if history.pushState
      @on 'page', (ctx) ->
        if ctx.replace
          # console.log "replacestate: ", ctx.state, ctx.canonicalPath
          history.replaceState ctx.state, '', ctx.canonicalPath
        else
          # console.log "pushstate: ", ctx.state, ctx.canonicalPath
          history.pushState ctx.state, '', ctx.canonicalPath

      window.addEventListener 'popstate', onpopstate, false
      highbrow.$(window).bind('click', onclick)

_.extend(Router.prototype, Backbone.Events)

