_ = require 'underscore'

#
# ## Highbrow ##
#


# [utils](utils.html)
module.exports = base = require './utils'

# [Model](model.html)
base.Model          = require './model'
# [Collection](collection.html)
base.Collection     = require './collection'
# [ViewModel](view-model.html)
base.ViewModel      = require './view-model'
# [ItemView](item-view.html)
base.ItemView       = require './item-view'
# [FormView](form-view.html)
formView            = require './form-view'
base.FormView       = formView.FormView
base.FormViewMixin  = formView.FormViewMixin
# [CollectionView](collection-view.html)
base.CollectionView = require './collection-view'
# [CompositeView](composite-view.html)
base.CompositeView  = require './composite-view'
base.RegionManager  = require './region-manager'
# [Application](application.html)
base.Application    = require './application'

# [Router](router.html)
base.Router         = require('./router')

base.handlers = require './handlers'

base.setViewModels = (viewModels) ->
  base.ItemView.viewModels = viewModels

_.extend(base.ItemView.prototype, base.BindTo)
_.extend(base.Model.prototype, base.BindTo)
