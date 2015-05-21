draftTitle = ->
  $("#draft_title")

suggestionBox = ->
  $("#suggestion_box")

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

ignoreBtn = ->
  $(".ignore_button a")

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

window.suggestionBox = ->
  draftTitle().click ->
    showSection('draft')

  boxTitle().click ->
    showSection('box') 
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
    acceptingTileVisibility("hide")

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
            $(".creation_placeholder").after data.tile
            window.updateTilesAndPlaceholdersAppearance()
          else
            acceptingTileVisibility("show")

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
    acceptTile()
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
        else
          tileVisibility tile, "show"

  ignoreBtn().click (e) ->
    e.preventDefault()
    ignoreTile $(@)
