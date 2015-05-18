draftSection = ->
  $("#draft")

box = ->
  $("#suggestion_box")

draftTitle = ->
  $("#draft_title")

boxTitle = ->
  $("#suggestion_box_title")

acceptBtn = ->
  $(".accept_button a")

acceptModalSel = ->
  "#accept-tile-modal"

acceptModal = ->
  $( acceptModalSel() )

confirmInAcceptModal = ->
  $( acceptModalSel() + " .confirm" )

undoInAcceptModal = ->
  $( acceptModalSel() + " .undo" )

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
  #
  # => Accept Tile Modal
  #
  prepareAccessModal = (acceptBtn) ->
    tile = acceptBtn.closest(".tile_container")
    tile.hide()

    window.accessActionParams =
      url: acceptBtn.attr("href")
      tile: acceptBtn.closest(".tile_container")
      undo: false

  acceptBtn().click (e) ->
    e.preventDefault()
    prepareAccessModal $(@)
    acceptModal().foundation('reveal', 'open')

  confirmInAcceptModal().click (e) ->
    e.preventDefault()
    acceptModal().foundation('reveal', 'close')

  undoInAcceptModal().click (e) ->
    e.preventDefault()
    window.accessActionParams["undo"] = true
    acceptModal().foundation('reveal', 'close')

  $(document).on 'closed.fndtn.reveal', acceptModalSel(), ->
    unless window.accessActionParams["undo"]
      $.ajax
        type: 'PUT'
        dataType: "json"
        url: window.accessActionParams["url"]
        success: (data) ->
          if data.success
            window.accessActionParams["tile"].remove()
            $(".creation_placeholder").after data.tile
          else
            window.accessActionParams["tile"].show()
    else
      window.accessActionParams["tile"].show()

