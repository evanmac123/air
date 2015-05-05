imageCreditView = ->
  $('.image_credit_view')

imageCreditInput = ->
  $('#tile_builder_form_image_credit')

maxLength = -> # max length of image credit text, obviously
  50

maxLengthAfterTruncation = ->
  maxLength() + '...'.length

isTooLong = ->
  imageCreditView().text().length > maxLengthAfterTruncation()

truncate = ->
  imageCreditView().text imageCreditView().text().substring(0, maxLength()) + '...'

getStatus = ->
  imageCreditView().data("status")

setStatus = (status) ->
  imageCreditView().data("status", status)  

isStatus = (status) ->
  getStatus() == status

backspaceKeyCode = ->
  8

hasTextInimageCreditView = ->
  imageCreditView().text().replace(/\s+/g, '').length > 0

truncateImageCreditView = ->
  if !isStatus('truncated') and isTooLong()
    truncate()
    setStatus 'truncated'

saveImageCreditChanges = (caller) ->
  if !hasTextInimageCreditView()
    setStatus('empty')
    text = ''
    if !imageCreditView().is(':focus') and caller != 'keyup'
      imageCreditView().text 'Add Image Credit'
  else if isStatus('truncated') #do nothing
    text = imageCreditInput().text()
  else if hasTextInimageCreditView()
    setStatus('')
    text = imageCreditView().text()

  imageCreditInput().text text

window.imageCredit = ->
  $(document).ready ->
    saveImageCreditChanges()
    truncateImageCreditView()

  imageCreditView().keyup ->
    saveImageCreditChanges 'keyup'
    truncateImageCreditView()

  imageCreditView().keydown (e) ->
    if isStatus('truncated') and e.keyCode == backspaceKeyCode()
      setStatus('')
      imageCreditView().text ''

  imageCreditView().click ->
    if isStatus('empty')
      imageCreditView().text('').focus()

  imageCreditView().focusout ->
    if isStatus('empty')
      imageCreditView().text 'Add Image Credit'

  imageCreditView().bind 'paste', ->
    imageCreditView().text('')
    setStatus('')