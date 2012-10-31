{ baseUrl: 'www/js/vendor'
, wrap: false
, optimize: 'none'
, shim:
  { 'nct': { exports: 'nct' }
  , 'backbone': { deps: ['underscore','jquery'], exports: 'Backbone' }
  , 'moment': { exports: 'moment' }
  , 'underscore': { exports: '_' }
  }
, paths:
  { 'backbone': 'empty:'
  , 'jquery': 'empty:'
  , 'nct': 'empty:'
  , 'model_binder': 'empty:'
  , 'moment': 'empty:'
  , 'underscore': 'empty:'
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

