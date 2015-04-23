blockSubmitButton = (counter) ->
  textLength = parseInt counter.text()
  if textLength < 0
    $("#publish input[type=submit]").attr('disabled', 'disabled')
    $(".supporting_content_error").show()
  else
    $("#publish input[type=submit]").removeAttr('disabled')
    $(".supporting_content_error").hide()
    
window.hedalineAndSupportingContentBuilder = ->
  addCharacterCounterFor('#tile_builder_form_headline')
  counterId = addCharacterCounterFor('#tile_builder_form_supporting_content')
  blockSubmitButton $("#" + counterId)

  $("#" + counterId).bind "DOMSubtreeModified", ->
    blockSubmitButton $(@)

  options =
    editor: document.getElementById('supporting_content_editor'), # {DOM Element} [required]
    list: [
      'bold'
      'italic'
      'underline'
      'insertorderedlist'
      'insertunorderedlist'
    ] # editor menu list
    #class: 'pen', # {String} class of the editor,
    #debug: false, # {Boolean} false by default
    #textarea: '<textarea name="content"></textarea>', # fallback for old browsers
    
  editor = new Pen(options)
