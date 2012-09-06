_ = require 'underscore'

module.exports = base = require './utils'

base.Model          = require './model'
base.Collection     = require './collection'
base.ViewModel      = require './view-model'
base.ItemView       = require './item-view'
formView            = require './form-view'
base.FormView       = formView.FormView
base.FormViewMixin  = formView.FormViewMixin
base.CollectionView = require './collection-view'
base.CompositeView  = require './composite-view'
base.RegionManager  = require './region-manager'
base.Application    = require './application'

base.Router         = require('./router')

base.setViewModels = (viewModels) ->
  base.ItemView.viewModels = viewModels

# _.extend(base.Controller.prototype, Backbone.Events)
# _.extend(base.Controller.prototype, base.BindTo)
_.extend(base.ItemView.prototype, base.BindTo)
# _.extend(base.CollectionView.prototype, base.BindTo)
