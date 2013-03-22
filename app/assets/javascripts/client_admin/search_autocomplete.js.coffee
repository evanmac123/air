jumpLinkSelected = (event, ui) ->
  window.location = ui.item.value
  event.preventDefault()

window.bindUserNameSearchAutocomplete = (sourceSelector, targetSelector, searchURL) ->
  $(sourceSelector).autocomplete({appendTo: targetSelector, source: searchURL, html: true, select: jumpLinkSelected})
