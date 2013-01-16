
class ErrorModel
  constructor: (@error,@model) ->
    @attrs = @error.attrs
    @message = @error.message || "Validation Failed"
    @errors = @error?.errors || []
    _.each (@errors), (err) =>
      @[err.field] = "error"
      messages =
        'missing': 'Missing'
        'missing_field': 'Required'
        'already_exists': 'Already exists'
        'invalid': 'Invalid'

      @[err.field+'_message'] = messages[err.code] if messages[err.code]
      @[err.field+'_message'] = err.message if err.message
