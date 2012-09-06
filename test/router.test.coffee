
Router = require '../lib/router'
e = require('chai').expect

# route = (path, fns...) -> new Route(path, fns...)

# describe "Route", ->
#   it "should match a static route", ->
#     e(route('/').match('/')).to.equal true

#   it "should match a path param", ->
#     e(route('/:name').match('/john').name).to.equal 'john'
#     params = route('/user/:name/:action').match('/user/john/sings')
#     e(params.name).to.equal 'john'
#     e(params.action).to.equal 'sings'

#   it "should set the default querystring to ''"
#   it "should expose the query string"
#   it "pathname: should set"
#   it "pathname: should be without querystring"
#   it "dispatcher: should ignore querystrings"

describe "Router", ->
  first = (ctx, next) ->
    ctx.first = true
    setTimeout next, 1

  it "should invoke a callback", (done) ->
    new Router().page('/', -> done()).show('/')

  it "should populate ctx.params", (done) ->
    r = new Router().page '/post/:slug', (ctx) ->
      e(ctx.params.slug).to.equal 'one'
      done()
    r.show '/post/one'

  it "should call the route functions with the router base as this", (done) ->
    r = new Router()
    r.msg = 'hello'
    r.page '/say', (ctx) ->
      e(@msg).to.equal 'hello'
      done()
    r.show '/say'

  it "should set ctx.root as Router root", (done) ->
    r = new Router()
    r.msg = 'hello'
    r.page '/say', (ctx) ->
      e(ctx.root.msg).to.equal 'hello'
      done()
    r.show '/say'

  it "should invoke multiple callbacks", (done) ->
    r = new Router().page '/multiple', first, (ctx) ->
      e(ctx.first).to.equal true
      ctx.first = false

    r.on 'show', (ctx, result) ->
      e(ctx.path).to.equal '/multiple'
      e(ctx.first).to.equal false
      done()

    r.show '/multiple'

  it "show should also return callback", (done) ->
    r = new Router().page '/multiple', first, ->
    r.show '/multiple', done

  it "should not follow the chain when error returned", (done) ->
    r = new Router()
    witherror = (ctx, next) -> next(404)
    r.page '/witherror', witherror, (ctx) ->
      throw new Error("Should not be reached")
    r.on 'show', -> throw new Error("Not reached")
    r.on 'error', (err,path,ctx,result) ->
      e(err).to.equal 404
      done()

    r.show '/witherror'


  it "should emit unhandled if no matching routes", (done) ->
    r = new Router()
    r.on 'unhandled', (ctx) ->
      e(ctx.path).to.equal '/unhandled'
      done()

    r.show '/unhandled'

describe "Mounted router", ->
  it "should allow a router to be mounted at a fixed base", (done) ->
    r = new Router()
    r.mount('/user').page '/show', (ctx) ->
      done()
    r.show '/user/show'

  it "should allow a router to be mounted with index page", (done) ->
    r = new Router()
    called = 0
    r.mount('/user').page '', (ctx) ->
      called += 1

    r.show '/user', ->
      r.show '/user/', (err, result, ctx) ->
        e(called).to.equal 2
        done()

  it "should run a mounted routers functions first", (done) ->
    r = new Router()
    user = r.mount '/user', (ctx,next) ->
      ctx.user = true
      next()

    user.page '/show', (ctx) ->
      e(ctx.user).to.equal true
      'OK'

    r.show '/user/show', (err, result) ->
      e(result).to.equal 'OK'
      done()

  it "multiple nested routers", (done) ->
    r = new Router()
    r.msg = 'hello'
    user = r.mount '/user', (ctx,next) ->
      ctx.user = true
      next()
    dashboard = user.mount '/dashboard', (ctx, next) ->
      ctx.dashboard = true
      e(@msg).to.equal 'hello'
      next()
    dashboard.page '/show', (ctx) ->
      e(ctx.user).to.equal true
      e(ctx.dashboard).to.equal true
      e(@msg).to.equal 'hello'
      'OK'
    r.show '/user/dashboard/show', (err, result) ->
      e(result).to.equal 'OK'
      e(@msg).to.equal 'hello'
      done()

  it "should set up params with multiple routers", (done) ->
    r = new Router()
    user = r.mount '/:user', (ctx,next) ->
      ctx.user = ctx.params.user
      next()
    user.page '/:id', (ctx) ->
      e(ctx.user).to.equal 'wvl'
      e(ctx.params.id).to.equal 'show'
      'OK'
    r.on 'show', (ctx, result) ->
      ctx.show = true
    r.show '/wvl/show', (err, result, ctx) ->
      e(err).to.not.exist
      e(result).to.equal 'OK'
      e(ctx.show).to.equal true
      done()

  it "should run base routers page first", (done) ->
    r = new Router()
    user = r.mount '/user', (ctx, next) ->
      next()
    user.page '/show', (ctx) ->
      throw new Error("Should not be called")
    r.page '/user/show', (ctx) -> done()
    r.show '/user/show'


    # public = router()
    # public.page 'login'
    # public.page 'logout'
    # public.page 'signup'
    # dashboard = router 'dashboard', users.loggedIn
    # settings = router 'settings', users.loggedIn
    # profiles = router ':username', users.find
    # router().mount 'dashboard', 


# describe "Router", ->
#   it "should match a basic route", (done) ->
#     router().page('/',done).show('/')
