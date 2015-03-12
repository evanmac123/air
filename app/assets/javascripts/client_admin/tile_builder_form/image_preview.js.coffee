imageUploaderId = ->
  'tile_builder_form_image'

imageUploader = ->
  $("#" + imageUploaderId())

imageFileTypes = ->
  [
    'image/bmp'
    'image/x-windows-bmp'
    'image/gif'
    'image/jpeg'
    'image/pjpeg'
    'image/x-portable-bmp'
    'image/png'
  ]

removeImageCredit = ->
  $('.image_credit_view').text('').trigger('keyup').trigger('focusout')

showPlaceholder = ->
  $('.image_preview').removeClass('show_shadows').addClass 'show_placeholder'

showShadows = ->
  $('.image_preview').removeClass('show_placeholder').addClass 'show_shadows'

getAttachedFile = ->
  document.getElementById(imageUploaderId()).files[0]

filetypeNotOnWhitelist = (file) ->
  type = file.type
  $.inArray(type, imageFileTypes()) == -1

badFileMessage = ->
  'Sorry, that doesn\'t look like an image file. Please use a file with the extension .jpg, .jpeg, .gif, .bmp or .png.'

showImgInPreview = (imgFile) ->
  oFReader = new FileReader
  oFReader.readAsDataURL imgFile
  oFReader.onload = (oFREvent) ->
    document.getElementById('upload_preview').src = oFREvent.target.result

recreateImageUploader = -> # is used to remove uploaded image
  imageUploader().replaceWith imageUploader().clone(true)

window.imagePreview = ->
  imageUploader().change (event) ->
    attachedFile = getAttachedFile()

    if filetypeNotOnWhitelist(attachedFile)
      alert badFileMessage()
      event.preventDefault()
      return false

    showImgInPreview(attachedFile)
    showShadows()

    $('#image_container').val ''
    $('#no_image').val ''

  $('.clear_image').click (event) ->
    event.preventDefault()
    $('#no_image').val 'true'
    recreateImageUploader()
    showPlaceholder()
    removeImageCredit()