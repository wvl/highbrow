# The default FormView class that can be
# used as a base class.
#
# No events are included. To use the default
# form view, pass 'handleFormSubmit' to the
# submit event of your form.
class FormView extends ItemView

server_error_message = """
There was an error communicating with the server.
"""
please_retry_message = """
Please try again in a few minutes. If the error persists,
please contact support.
"""

# The basic form view is included here as a MixIn that can
# be mixed into other views.
#
# It provides a default implementation of syncing a form
# to a model, and a submit event handler that will
# save the model to the server.
FormViewMixin =
  initialize: ->
    @binder = new Backbone.ModelBinder() if Backbone.ModelBinder and highbrow.browser and @model

  # override for custom handling
  formToObject: -> @$('form').toObject()

  # Take xhr response, and build error object
  _handleError: (res) ->
    if res.status == 401
      @trigger 'unauthorized'
      @error = {message: unauthorized_message}

    if res.status in [502,504] # bad gateway, gateway timeout
      message = server_error_message
      message += '\n' + please_retry_message
      @error = {message}

    # forbidden, not found, unprocessable entity
    if res.status in [403,404,422]
      try
        @error = if res.responseText then JSON.parse(res.responseText) else res
      catch e
        @error = {message: "Error"}

    if !res.status
      @error = res

    @error.message ?= "Error"

  onRender: ->
    @binder.bind @model, @$el if @binder

  wysihtml5ParserRules:
    tags:
      strong: {}, b: {}, i: {}, em: {}, br: {}, p: {},
      div: {}, span: {}, ul: {}, ol: {}, li: {},
      a:
        set_attributes:
          target: "_blank"
          rel:    "nofollow"
        check_attributes:
          href:   "url" # important to avoid XSS

  handleFormSubmit: (e) ->
    e.preventDefault()

    callbacks =
      success: (model, resp) =>
        @trigger 'success', @model

      error: (model, response, options) =>
        @_handleError(response)
        # console.log "Handle error", model, response, options
        @rerender()
        @trigger 'error', @error

    @error = @model.savable()
    return @rerender() if @error

    if @collection
      @collection.create(@model, callbacks)
    else
      @model.save({}, callbacks)

_.extend FormView.prototype, FormViewMixin
