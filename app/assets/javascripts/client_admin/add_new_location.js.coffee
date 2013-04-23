startLoadingFeedback = () ->
  # disable dropdown
  $('#adding_location img').show()
  $('select#user_location_id').attr disabled: 'disabled'

stopLoadingFeedback = () ->
  # reenable dropdown
  $('#adding_location img').hide()


updateLocationList = (selector) ->
  (data) -> 
    $(selector).replaceWith(data)




createNewLocation = (selector, addOptionValue, postURL) ->
  (event) ->
    selectedValue = $(event.target).val()
    return unless selectedValue == addOptionValue
    
    newLocationName = window.prompt "What shall we call the new location?"
    if newLocationName
      startLoadingFeedback()
      postOptions = {name: newLocationName}
      $.post(postURL, postOptions, updateLocationList(selector), 'html').complete(stopLoadingFeedback)




window.bindNewLocationCreation = (selector, addOptionText, postURL) ->
  $(document).on('change', selector, createNewLocation(selector, addOptionText, postURL))
