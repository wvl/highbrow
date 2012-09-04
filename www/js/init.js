require.config({
  baseUrl: 'js'
, paths:
  { 'jquery': 'vendor/jquery'
  , 'underscore': 'vendor/underscore'
  , 'backbone': 'vendor/backbone'
  , 'moment': 'vendor/moment'
  , 'nct': 'vendor/nct'
  , 'socket.io': 'vendor/socket.io.min'
  , 'model_binder': 'vendor/model_binder'
  , 'highbrow': 'vendor/highbrow'
  }
, shim:
  { 'backbone': { deps: ['underscore','jquery'], exports: 'Backbone' }
  , 'underscore': { exports: '_' }
  , 'moment': { exports: 'moment' }
  , 'nct': { exports: 'nct' }
  , 'model_binder': { deps: ['backbone'] }
  }
})
