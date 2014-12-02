startLoadingFeedback = (triggeringSelectSelector, spinnerSelector) ->
  # disable dropdown
  $(spinnerSelector).show()
  $(triggeringSelectSelector).attr disabled: 'disabled'

stopLoadingFeedback = (spinnerSelector) ->
  # reenable dropdown
  $(spinnerSelector).hide()

resetFoundationCustomList = (listSelector) ->
  if window.triggeringSelectSelectorDataId
    $(listSelector).attr("data-id", window.triggeringSelectSelectorDataId)
    window.triggeringSelectSelectorDataId = null
    $(listSelector).trigger("change", true).addClass("hidden-field")

updateItemList = (listSelector, spinnerSelector) ->
  (data) ->
    $(listSelector).replaceWith(data)
    stopLoadingFeedback(spinnerSelector)
    resetFoundationCustomList listSelector

resetForm = ($form) ->
    $form.find('input:text, input:password, input:file, select, textarea').val('')
    $form.find('input:radio, input:checkbox').removeAttr('checked').removeAttr('selected')

createNewItem = (triggeringSelectSelector, lightboxSelector, creationURL, spinnerSelector, callback) ->
  (event) ->
    callback ?= updateItemList(triggeringSelectSelector, spinnerSelector)
    event.preventDefault()

    lightbox = $(lightboxSelector)

    params = lightbox.find('form').serialize()

    lightbox.trigger('close')

    startLoadingFeedback(triggeringSelectSelector, spinnerSelector)
    window.triggeringSelectSelectorDataId = $(triggeringSelectSelector).attr("data-id")
    $.post creationURL, params, callback, 'html'

    resetForm lightbox.find('form')




focusItemName = (lightbox) ->
  () -> lightbox.find('input[type=text]').focus()



showNewItemLightbox = (triggeringValue, lightboxSelector) ->
  (event) ->
    if $(event.target).val() == triggeringValue
      event.preventDefault()
      lightbox = $(lightboxSelector)
      lightbox.lightbox_me(onLoad: focusItemName(lightbox))




window.bindShowNewItemLightbox = (triggeringSelectSelector, triggeringValue, lightboxSelector, creationURL, spinnerSelector, callback) ->
  lightboxSelectorForm = lightboxSelector + ' form'
  $("body").on('submit', lightboxSelectorForm, createNewItem(triggeringSelectSelector, lightboxSelector, creationURL, spinnerSelector, callback))
  $("body").on('change', triggeringSelectSelector, showNewItemLightbox(triggeringValue, lightboxSelector))
