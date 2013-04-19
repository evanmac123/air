startLoadingFeedback = () ->
  # stub stub
  console.log 'starting feedback'

stopLoadingFeedback = () ->
  # stub stub
  console.log 'stopping feedback'


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
