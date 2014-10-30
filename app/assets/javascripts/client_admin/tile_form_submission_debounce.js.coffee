window.bindDebounceTileSubmit = (formSelector) ->
  $(formSelector).submit (event) ->
    form = $(event.target)
    form.attr('disabled', 'disabled')
    form.find('input[type=submit]').attr('disabled', 'disabled')
