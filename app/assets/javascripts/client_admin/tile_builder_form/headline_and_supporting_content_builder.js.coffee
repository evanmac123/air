contentEditorSel = ->
  '#supporting_content_editor'

contentEditor = ->
  $(contentEditorSel())

contentInput = ->
  $('#tile_builder_form_supporting_content')

blockSubmitButton = (counter) ->
  textLength = parseInt counter.text()
  submitBtn = $("#publish input[type=submit]")
  errorContainer = $(".supporting_content_error")

  if textLength < 0
    submitBtn.attr('disabled', 'disabled')
    errorContainer.show()
  else
    submitBtn.removeAttr('disabled')
    errorContainer.hide()

updateContentInput = ->
  contentInput().val contentEditor().html()

initializeSupportingContentEditor = ->
  options =
    editor: (contentEditor())[0],
    list: [
      'bold'
      'italic'
      'underline'
      'insertorderedlist'
      'insertunorderedlist'
    ]
  editor = new Pen(options)
    
window.hedalineAndSupportingContentBuilder = ->
  addCharacterCounterFor('#tile_builder_form_headline')
  counterId = addCharacterCounterFor(contentEditorSel())
  blockSubmitButton $("#" + counterId)
  initializeSupportingContentEditor()

  $("#" + counterId).bind "DOMSubtreeModified", ->
    blockSubmitButton $(@)

  contentEditor().bind "DOMSubtreeModified", ->
    updateContentInput()