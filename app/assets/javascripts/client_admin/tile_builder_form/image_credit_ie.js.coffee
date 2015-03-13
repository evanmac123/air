maxLength = -> # max length of image credit text, obviously
  50

imageCreditView = ->
  $('.image_credit_view')

imageCreditInputSelector = ->
  '#tile_builder_form_image_credit'

imageCreditInput = ->
  $(imageCreditInputSelector)

normalizedImageCreditInput = ->
  inputted_text = imageCreditInput().val()
  if inputted_text != ''
    if inputted_text.length > maxLength()
      inputted_text.substring(0, maxLength()) + '...'
    else
      inputted_text
  else
    'Add Image Credit'

updateImageCreditView = ->
  text = normalizedImageCreditInput()
  imageCreditView().html text

window.imageCreditIE = ->
  $(document).ready ->
    updateImageCreditView()
    addCharacterCounterFor imageCreditInputSelector()

  imageCreditInput().bind 'input propertychange', ->
    updateImageCreditView()