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
    draftSection().addClass('selected')
    box().removeClass('selected')
  else
    draftSection().removeClass('selected')
    box().addClass('selected')
  updateShowMoreDraftTilesButton()
  window.compressSection()

window.suggestionBox = ->
  draftTitle().click ->
    showSection('draft')

  boxTitle().click ->
    showSection('box') 
