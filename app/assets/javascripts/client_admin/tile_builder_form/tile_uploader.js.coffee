removeImageCredit = ->
  $('.image_credit_view').text('').trigger('keyup').trigger('focusout')

window.bindTileUploader = ->

  showPlaceholder = ->
    $('.image_preview').removeClass('show_shadows').addClass 'show_placeholder'

  showShadows = ->
    $('.image_preview').removeClass('show_placeholder').addClass 'show_shadows'

  filetypeNotOnWhitelist = (file) ->
    type = file.type
    $.inArray(type, imageFileTypes) == -1

  # saveImageCreditChanges = (caller) ->
  #   div_input = $('.image_credit_view')
  #   #check if we have any text in div(delete spaces)
  #   text_length = div_input.text().replace(/\s+/g, '').length
  #   if text_length == 0
  #     div_input.addClass('empty').removeClass 'truncate'
  #     if !div_input.is(':focus') and caller != 'keyup'
  #       div_input.text 'Add Image Credit'
  #     text = ''
  #   else if div_input.hasClass('truncate')
  #     text = $('#tile_builder_form_image_credit').text()
  #     #do nothing
  #   else if text_length > 0
  #     div_input.removeClass 'empty'
  #     text = div_input.text()
  #   $('#tile_builder_form_image_credit').text text

  # truncateImageCreditView = ->
  #   div_input = $('.image_credit_view')
  #   text = div_input.text()
  #   if !div_input.hasClass('truncate') and text.length > MAX_IMAGE_CREDIT_LENGTH + 3
  #     div_input.text div_input.text().substring(0, 50) + '...'
  #     div_input.addClass 'truncate'

  # $(document).ready ->
  #   # window.MAX_IMAGE_CREDIT_LENGTH = 50
  #   saveImageCreditChanges()
  #   truncateImageCreditView()

  imageFileTypes = [
    'image/bmp'
    'image/x-windows-bmp'
    'image/gif'
    'image/jpeg'
    'image/pjpeg'
    'image/x-portable-bmp'
    'image/png'
  ]

  $('#tile_builder_form_image').change (event) ->
    attachedFile = document.getElementById('tile_builder_form_image').files[0]
    if filetypeNotOnWhitelist(attachedFile)
      alert 'Sorry, that doesn\'t look like an image file. Please use a file with the extension .jpg, .jpeg, .gif, .bmp or .png.'
      event.preventDefault()
      return false
    oFReader = new FileReader
    oFReader.readAsDataURL attachedFile

    oFReader.onload = (oFREvent) ->
      document.getElementById('upload_preview').src = oFREvent.target.result

    $('#image_container').val ''
    $('#no_image').val ''
    showShadows()

  $('.clear_image').click (event) ->
    event.preventDefault()
    $('#no_image').val 'true'
    control = $('#tile_builder_form_image')
    control.replaceWith control = control.clone(true)
    showPlaceholder()
    removeImageCredit()

  # $('.image_credit_view').keyup ->
  #   saveImageCreditChanges 'keyup'
  #   truncateImageCreditView()

  # $('.image_credit_view').keydown (e) ->
  #   div_input = $(this)
  #   if div_input.hasClass('truncate') and e.keyCode == 8
  #     #backspace
  #     div_input.removeClass 'truncate'
  #     div_input.text ''

  # $('.image_credit_view').click ->
  #   if $(this).hasClass('empty')
  #     $(this).text('').focus()

  # $('.image_credit_view').focusout ->
  #   if $(this).hasClass('empty')
  #     $(this).text 'Add Image Credit'

  # $('.image_credit_view').bind 'paste', ->
  #   $('.image_credit_view').text('').addClass('remove').removeClass 'truncate'