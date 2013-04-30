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
    stopLoadingFeedback()


createNewLocation = (locationSelectSelector, lightboxSelector, creationURL) ->
  (event) ->
    event.preventDefault()

    lightbox = $(lightboxSelector)

    params = lightbox.find('form').serialize()

    lightbox.trigger('close')

    startLoadingFeedback()
    $.post creationURL, params, updateLocationList(locationSelectSelector), 'html'




focusLocationName = (lightbox) ->
  () -> lightbox.find('input[type=text]').focus()



showNewLocationLightbox = (triggeringValue, lightboxSelector) ->
  (event) ->
    if $(event.target).val() == triggeringValue
      event.preventDefault()
      lightbox = $(lightboxSelector)
      lightbox.lightbox_me(onLoad: focusLocationName(lightbox))




window.bindShowNewLocationLightbox = (locationSelectSelector, triggeringValue, lightboxSelector, creationURL) ->
  $(lightboxSelector).find('form').on('submit', createNewLocation(locationSelectSelector, lightboxSelector, creationURL))
  $(locationSelectSelector).on('change', showNewLocationLightbox(triggeringValue, lightboxSelector))
