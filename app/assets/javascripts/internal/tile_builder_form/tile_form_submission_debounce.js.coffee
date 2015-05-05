window.bindDebounceTileSubmit = (formSelector) ->
  form = $(formSelector)
  submitButton = form.find('input[type=submit]')

  submitButton.click (event) ->
    submitButton.attr('disabled', 'disabled')
    form.submit()
