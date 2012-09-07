{ baseUrl: 'www/js/vendor'
, wrap: false
, optimize: 'none'
, shim:
  { 'nct': { exports: 'nct' }
  , 'backbone': { deps: ['underscore','jquery'], exports: 'Backbone' }
  , 'moment': { exports: 'moment' }
  , 'underscore': { exports: '_' }
  }
, dir: 'release'
, packages: [
    {name: 'highbrow', location: 'highbrow', main: 'index'}
  ]
, modules:
  [ { name: 'highbrow'
    , exclude: ['nct','backbone','moment','underscore','model_binder']
    }
  ]
}

