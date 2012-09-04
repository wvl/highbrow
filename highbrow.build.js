{ baseUrl: 'www/js/vendor'
, wrap: false
, exclude: ['nct','backbone','moment','underscore','model_binder']
, optimize: 'none'
, paths:
  { 'backbone': 'empty:' //../node_modules/backbone/backbone'
  , 'jquery': 'empty:' //'../vendor/jquery-1.8.1.min'
  , 'nct': 'empty:' //'../node_modules/nct/dist/nct'
  , 'underscore': 'empty:' //'../node_modules/underscore/underscore'
  , 'moment': 'empty:' //'../node_modules/moment/moment'
  , 'model_binder': 'empty:' //'../vendor/Backbone.ModelBinder'
  }
, shim:
  { 'nct': { exports: 'nct' }
  , 'backbone': { deps: ['underscore','jquery'], exports: 'Backbone' }
  , 'moment': { exports: 'moment' }
  , 'underscore': { exports: '_' }
  }
, name: 'highbrow'
, out: 'dist/highbrow.js'
, packages: [
    {name: 'highbrow', location: 'highbrow', main: 'index'}
  ]
}

