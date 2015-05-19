contentEditorSel = ->
  '#supporting_content_editor'

contentEditor = ->
  $(contentEditorSel())

contentEditorMaxlength = ->
  contentEditor().next().attr('maxlength') #counter

contentInput = ->
  $('#tile_builder_form_supporting_content')

blockSubmitButton = (counter) ->
  textLeftLength = contentEditor().text().length
  submitBtn = $("#publish input[type=submit]")
  errorContainer = $(".supporting_content_error")

  if textLeftLength > contentEditorMaxlength()
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
    ],
    stay: false
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
contentEditorModifiedEvents = () ->
  window.lastEditorLength = editorLength()

  contentEditor().bind "DOMSubtreeModified", ->
    if editorLength() != window.lastEditorLength
      window.lastEditorLength = editorLength()

      blockSubmitButton()
      updateContentInput()
    
window.headlineAndSupportingContentBuilder = ->
  addCharacterCounterFor('#tile_builder_form_headline')
  addCharacterCounterFor contentEditorSel()
  blockSubmitButton()
  initializeSupportingContentEditor()
  contentEditorModifiedEvents()

  # convert pasted content to plain text. ie does it automatically
  pasteNoFormattingIE = ->
    text = window.clipboardData.getData("text") || ""
    if (text != "")
      if (window.getSelection)
        newNode = document.createElement("span")
        newNode.innerHTML = text
        window.getSelection().getRangeAt(0).insertNode(newNode)
      else
        document.selection.createRange().pasteHTML(text)

  contentEditor().on 'paste', (e) ->
    e.preventDefault()
    if isIE()
      pasteNoFormattingIE()
    else
      text = (e.originalEvent || e).clipboardData.getData('text/plain')
      window.document.execCommand('insertText', false, text)
