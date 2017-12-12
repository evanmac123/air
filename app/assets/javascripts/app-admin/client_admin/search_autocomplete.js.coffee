jumpLinkSelected = (event, ui) ->
  if ui.item.value.found
    window.location = ui.item.value.url
  else
    fillInAndFocusNameField(ui.item.value.name)
  event.preventDefault()

fillInAndFocusNameField = (name) ->
  userNameField = $('#user_name')
  userNameField.val(name).focus()

window.bindUserNameSearchAutocomplete = (sourceSelector, targetSelector, searchURL) ->
  $(sourceSelector).autocomplete
    appendTo: targetSelector, 
    source:   searchURL, 
    html:     'html', 
    select:   jumpLinkSelected,
    focus:    (event) -> event.preventDefault()
