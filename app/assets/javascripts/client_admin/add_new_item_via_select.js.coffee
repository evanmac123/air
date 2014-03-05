startLoadingFeedback = (triggeringSelectSelector, spinnerSelector) ->
  # disable dropdown
  $(spinnerSelector).show()
  $(triggeringSelectSelector).attr disabled: 'disabled'

stopLoadingFeedback = (spinnerSelector) ->
  # reenable dropdown
  $(spinnerSelector).hide()


updateItemList = (listSelector, spinnerSelector) ->
  (data) ->
    $(listSelector).replaceWith(data)
    stopLoadingFeedback(spinnerSelector)


createNewItem = (triggeringSelectSelector, lightboxSelector, creationURL, spinnerSelector) ->
  (event) ->
    event.preventDefault()

    lightbox = $(lightboxSelector)

    params = lightbox.find('form').serialize()

    lightbox.trigger('close')

    startLoadingFeedback(triggeringSelectSelector, spinnerSelector)
    $.post creationURL, params, updateItemList(triggeringSelectSelector, spinnerSelector), 'html'




focusItemName = (lightbox) ->
  () -> lightbox.find('input[type=text]').focus()



showNewItemLightbox = (triggeringValue, lightboxSelector) ->
  (event) ->
    if $(event.target).val() == triggeringValue
      event.preventDefault()
      lightbox = $(lightboxSelector)
      lightbox.lightbox_me(onLoad: focusItemName(lightbox))




window.bindShowNewItemLightbox = (triggeringSelectSelector, triggeringValue, lightboxSelector, creationURL, spinnerSelector) ->
  $(lightboxSelector).find('form').on('submit', createNewItem(triggeringSelectSelector, lightboxSelector, creationURL, spinnerSelector))
  $(triggeringSelectSelector).on('change', showNewItemLightbox(triggeringValue, lightboxSelector))
