
highbrow.Backbone = Backbone
highbrow.nct = nct



#
# ## Highbrow ##
#


# [utils](utils.html)

# [Model](model.html)
highbrow.Model          = Model
# [Collection](collection.html)
highbrow.Collection     = Collection
# [PaginatedCollection](paginated-collection.html)
highbrow.PaginatedCollection = PaginatedCollection
# [ViewModel](view-model.html)
highbrow.ViewModel      = ViewModel
# [ItemView](item-view.html)
highbrow.ItemView       = ItemView
# [FormView](form-view.html)
highbrow.FormView       = FormView
highbrow.FormViewMixin  = FormViewMixin
# [CollectionView](collection-view.html)
highbrow.CollectionView = CollectionView
# [CompositeView](composite-view.html)
highbrow.CompositeView  = CompositeView
# [Application](application.html)
highbrow.Application    = Application

# [Router](router.html)
highbrow.Router         = Router

highbrow.setViewModels = (viewModels) ->
  highbrow.ItemView.viewModels = viewModels

_.extend(highbrow.ItemView.prototype, highbrow.BindTo)
_.extend(highbrow.Model.prototype, highbrow.BindTo)
_.extend(highbrow.Collection.prototype, highbrow.BindTo)
