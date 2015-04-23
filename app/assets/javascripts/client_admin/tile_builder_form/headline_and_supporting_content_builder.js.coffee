contentEditor = ->
  $('#supporting_content_editor')

contentInput = ->
  $('#tile_builder_form_supporting_content')

blockSubmitButton = (counter) ->
  textLength = parseInt counter.text()
  if textLength < 0
    $("#publish input[type=submit]").attr('disabled', 'disabled')
    $(".supporting_content_error").show()
  else
    $("#publish input[type=submit]").removeAttr('disabled')
    $(".supporting_content_error").hide()

updateContentInput = ->
  contentInput().val contentEditor().html()

initializeContentEditor = ->
  options =
    editor: (contentEditor())[0], # {DOM Element} [required]
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
    
window.hedalineAndSupportingContentBuilder = ->
  addCharacterCounterFor('#tile_builder_form_headline')
  counterId = addCharacterCounterFor('#tile_builder_form_supporting_content')
  blockSubmitButton $("#" + counterId)
  initializeContentEditor()

  $("#" + counterId).bind "DOMSubtreeModified", ->
    blockSubmitButton $(@)

  contentEditor().bind "DOMSubtreeModified", ->
    updateContentInput()