draftTitle = ->
  $("#draft_title")

suggestionBox = ->
  $("#suggestion_box")

boxTitle = ->
  $("#suggestion_box_title")

acceptBtnSel = ->
  ".accept_button a"

acceptBtn = ->
  $( acceptBtnSel() )

acceptModalSel = ->
  "#accept-tile-modal"

acceptModal = ->
  $( acceptModalSel() )

confirmInAcceptModal = ->
  $( acceptModalSel() + " .confirm" )

undoInAcceptModal = ->
  $( acceptModalSel() + " .undo" )

ignoreBtnSel = ->
  ".ignore_button a"

ignoreBtn = ->
  $( ignoreBtnSel() )

undoIgnoreBtnSel = ->
  ".undo_ignore_button a"

undoIgnoreBtn = ->
  $( undoIgnoreBtnSel() )

submittedTile = ->
  $(".tile_thumbnail.user_submitted").closest(".tile_container")

showSection = (section) ->
  if section == 'draft'
    $("#draft_tiles")
      .addClass('draft_selected')
      .removeClass('suggestion_box_selected')
  else
    $("#draft_tiles")
      .removeClass('draft_selected')
      .addClass('suggestion_box_selected')

  updateShowMoreDraftTilesButton()
  window.compressSection()

tileVisibility = (tile, action) ->
  if action == "show"
    tile.removeClass("hidden_tile").show()
  else if action == "hide"
    tile.addClass("hidden_tile").hide()
  else if action == "remove"
    tile.remove()
  window.updateTilesAndPlaceholdersAppearance()

removeNewTileTip = ->
  $(".joyride-tip-guide.tile").remove()

ping = (action) ->
  $.post "/ping", {event: 'Suggestion Box', properties: {client_admin_action: action}}

window.acceptModalForTileFromPreviewPage = (url) ->
  window.accessActionParams =
    url: url
    undo: false
    ajax: false
  acceptModal().foundation('reveal', 'open')

window.suggestionBox = ->
  draftTitle().click ->
    showSection('draft')

  boxTitle().click ->
    removeNewTileTip()
    showSection('box') 
    ping("Suggestion Box Opened")
  #
  # => Accept Tile Modal
  #
  acceptingTileVisibility = (action) ->
    tile = window.accessActionParams["tile"]
    tileVisibility(tile, action)

  prepareAccessModal = (acceptBtn) ->
    tile = acceptBtn.closest(".tile_container")
    window.accessActionParams =
      url: acceptBtn.attr("href")
      tile: tile
      undo: false
      ajax: true
    acceptingTileVisibility("hide")

  updateUserSubmittedTilesCounter = ->
    $("#user_submitted_tiles_counter").html submittedTile().length

  acceptTileFromPreviewPage = ->
    if window.accessActionParams["undo"]
      $.ajax
        type: 'PUT'
        dataType: "json"
        url: window.accessActionParams["url"]
        success: (data) ->
          window.location.href = "/client_admin/tiles/" + data.tile_id
    window.accessActionParams = {}


  acceptTile = ->
    if window.accessActionParams["undo"]
      acceptingTileVisibility("show")
    else
      $.ajax
        type: 'PUT'
        dataType: "json"
        url: window.accessActionParams["url"]
        success: (data) ->
          if data.success
            acceptingTileVisibility("remove")
            $("#draft .no_tiles_section").after data.tile
            window.updateTilesAndPlaceholdersAppearance()
            updateUserSubmittedTilesCounter()
          else
            acceptingTileVisibility("show")

  $(document).on 'click', acceptBtnSel(), (e) ->
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
    if window.accessActionParams["ajax"]
      acceptTile()
    else
      acceptTileFromPreviewPage()
  #
  # => Ignore Tile
  #
  insertIgnoredTile = (tile) ->
    if submittedTile().length > 0
      submittedTile().last().after tile
    else
      suggestionBox().append tile
    window.updateTilesAndPlaceholdersAppearance()

  ignoreTile = (ignoreButton) ->
    tile = ignoreButton.closest(".tile_container")
    url = ignoreButton.attr("href")

    tileVisibility tile, "hide"
    $.ajax
      type: 'PUT'
      dataType: "json"
      url: url
      success: (data) ->
        if data.success
          tileVisibility tile, "remove"
          insertIgnoredTile data.tile
          updateUserSubmittedTilesCounter()
        else
          tileVisibility tile, "show"

  $(document).on 'click', ignoreBtnSel(), (e) ->
    e.preventDefault()
    ignoreTile $(@)
  #
  # => Undo Ignore Tile
  #
  insertUserSubmittedTile = (tile) ->
    if submittedTile().length > 0
      submittedTile().first().before tile
    else
      suggestionBox().append tile
    window.updateTilesAndPlaceholdersAppearance()

  undoIgnoreTile = (button) ->
    tile = button.closest(".tile_container")
    url = button.attr("href")

    tileVisibility tile, "hide"
    $.ajax
      type: 'PUT'
      dataType: "json"
      url: url
      success: (data) ->
        if data.success
          tileVisibility tile, "remove"
          insertUserSubmittedTile data.tile
          updateUserSubmittedTilesCounter()
        else
          tileVisibility tile, "show"

  $(document).on 'click', undoIgnoreBtnSel(), (e) ->
    e.preventDefault()
    undoIgnoreTile $(@)
