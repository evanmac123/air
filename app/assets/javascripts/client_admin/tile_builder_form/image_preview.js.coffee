imageUploaderId = ->
  'tile_builder_form_image'

imageUploader = ->
  $("#" + imageUploaderId())

imageContainer = ->
  $('#image_container')

noImage = ->
  $('#no_image')

imageFromLibraryField = ->
  $("#image_from_library")

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

setPreviewImage = (imageUrl) ->
  document.getElementById('upload_preview').src = imageUrl

isIE = ->
  myNav = navigator.userAgent.toLowerCase()
  if (myNav.indexOf('msie') != -1) 
    parseInt(myNav.split('msie')[1]) 
  else
    false

showImgInPreview = (imgFile) ->
  oFReader = new FileReader
  oFReader.readAsDataURL imgFile
  oFReader.onload = (oFREvent) ->
    setPreviewImage(oFREvent.target.result)

    

recreateImageUploader = -> # is used to remove uploaded image
  imageUploader().replaceWith imageUploader().clone(true)

updateHiddenImageFields = (caller) ->
  imageContainer().val ''
  noImage().val ''
  imageFromLibraryField().val ''
  
  if caller == 'imageUploader'
    return
  else if caller == 'clearImage'
    noImage().val 'true'
  else if caller == 'imageFromLibrary'
    imageFromLibraryField().val selectedImageTileId()

window.imagePreview = ->
  imageUploader().change (event) ->
    if 0 < isIE() < 10
      showPlaceholder()
    else
      attachedFile = getAttachedFile()

      if filetypeNotOnWhitelist(attachedFile)
        alert badFileMessage()
        event.preventDefault()
        return false

      showImgInPreview(attachedFile)
      updateHiddenImageFields('imageUploader')
      showShadows()

  $('.clear_image').click (event) ->
    event.preventDefault()
    updateHiddenImageFields('clearImage')
    recreateImageUploader()
    showPlaceholder()
    removeImageCredit()

#
# => Image Library Part
#
imageFromLibrary = ->
  $(".tile_image_block:not(.upload_image)")

selectedImageFromLibrary = ->
  imageFromLibrary().filter(".selected")

selectedImageTileId = ->
  selectedImageFromLibrary().data('tile-image-id')

setSelectedState = (imageBlock) ->
  imageFromLibrary().removeClass('selected')
  imageBlock.addClass('selected')

mainImageUrl = (imageBlock) ->
  imageBlock.data('image-url')

showImgFromLibraryInPreview = (imageBlock) ->
  setPreviewImage mainImageUrl(imageBlock)

select = (imageBlock) ->
  setSelectedState(imageBlock)
  updateHiddenImageFields('imageFromLibrary')
  showImgFromLibraryInPreview(imageBlock)
  showShadows()

window.imageLibrary = ->
  imageFromLibrary().click ->
    imageBlock = $(this)
    select(imageBlock)
    recreateImageUploader()
  