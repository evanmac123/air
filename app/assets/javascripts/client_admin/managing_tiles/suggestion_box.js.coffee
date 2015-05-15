draftSection = ->
  $("#draft")

box = ->
  $("#suggestion_box")

draftTitle = ->
  $("#draft_title")

boxTitle = ->
  $("#suggestion_box_title")

showSection = (section) ->
  if section == 'draft'
    draftSection().show()
    box().hide()
  else
    draftSection().hide()
    box().show()

window.suggestionBox = ->
  showSection('draft') 

  draftTitle().click ->
    showSection('draft')

  boxTitle().click ->
    showSection('box') 
