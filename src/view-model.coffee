class ViewModel
  constructor: (@model, error) ->
    @error = new ErrorModel(error,@model) if error
    @attrs = @error?.attrs || {}
    @initialize(@model) if @initialize

  hasError: -> @error?.errors?.length

  # get from error object first if its there, otherwise from model
  get: (attr) ->
    attr = if @attrs.hasOwnProperty(attr) then @attrs[attr] else @model.get(attr)
    if attr is undefined or attr is null then "" else attr

  isNew: -> @model.isNew()
  id: -> @model.id || @model.cid

  @attrs: (list) ->
    list.forEach (attr) =>
      @prototype[attr] = -> @get(attr) || ""

  @pass: (attrs) ->
    list = if _.isArray(attrs) then attrs else [attrs]
    list.forEach (attr) =>
      @prototype[attr] = (args...) -> @model[attr](args)

  @date: (attrs) ->
    list = if _.isArray(attrs) then attrs else [attrs]
    list.forEach (attr) =>
      @prototype[attr] = -> moment(@get(attr))

  @boolean: (attrs) ->
    _.each (if _.isArray(attrs) then attrs else [attrs]), (attr) =>
      @prototype[attr] = -> @model.get(attr) || ""
      @prototype[attr+'Checked'] = ->
        if @model.get(attr) then "checked='checked'" else ""

  @model: (name, viewModel) ->
    @prototype[name] = -> @model[name] && new viewModel(@model[name])

  @collection: (name, viewModel) ->
    @prototype[name+'_length'] = -> (@model[name] || []).length

    @prototype[name] = ->
      (@model[name] || []).map (m) -> new viewModel(m)

  @collection_in: (name, viewModel) ->
    @prototype[name] = ->
      vm = if viewModel.name=='' then viewModel() else viewModel
      new vm(@model.collection.parent)


  # model view url
  mvurl: (ctx, params) ->
    "/app"+@model.path(params[0] || '')

  has: (ctx, params) ->
    return false unless params.length
    attr = params[0]
    if _.has(@attrs,attr) then @attrs[attr] else @model.get(attr)

ViewModel.extend = Backbone.View.extend
