contentEditorSel = ->
  '#supporting_content_editor'

contentEditor = ->
  $(contentEditorSel())

contentInput = ->
  $('#tile_builder_form_supporting_content')

counterLength = (counter) ->
  parseInt counter.text()

blockSubmitButton = (counter) ->
  textLeftLength = counterLength(counter)
  submitBtn = $("#publish input[type=submit]")
  errorContainer = $(".supporting_content_error")

  if textLeftLength < 0
    submitBtn.attr('disabled', 'disabled')
    errorContainer.show()
  else
    submitBtn.removeAttr('disabled')
    errorContainer.hide()

updateContentInput = ->
  contentInput().val contentEditor().html()

initializeSupportingContentEditor = ->
  options =
    #debug: true,
    editor: (contentEditor())[0],
    list: [
      'bold'
      'italic'
      'underline'
      'insertorderedlist'
      'insertunorderedlist'
      'createlink'
    ]
  editor = new Pen(options)

isIE = ->
  myNav = navigator.userAgent.toLowerCase()
  if (myNav.indexOf('msie') != -1) 
    parseInt(myNav.split('msie')[1]) 
  else
    false

editorLength = ->
  contentEditor().html().length

# need to make length checking because ie9 and ie10
# fire DOMSubtreeModified like crazy
contentEditorModifiedEvents = (counter) ->
  window.lastEditorLength = editorLength()

  contentEditor().bind "DOMSubtreeModified", ->
    if editorLength() != window.lastEditorLength
      window.lastEditorLength = editorLength()

      blockSubmitButton counter
      updateContentInput()
    
window.hedalineAndSupportingContentBuilder = ->
  addCharacterCounterFor('#tile_builder_form_headline')
  counterId = addCharacterCounterFor(contentEditorSel())
  counter = $("#" + counterId)

  blockSubmitButton counter
  initializeSupportingContentEditor()
  contentEditorModifiedEvents(counter)

  # convert pasted content to plain text. ie does it automatically
  contentEditor().on 'paste', (e) ->
    unless isIE()
      e.preventDefault()
      text = (e.originalEvent || e).clipboardData.getData('text/plain')
      window.document.execCommand('insertText', false, text)