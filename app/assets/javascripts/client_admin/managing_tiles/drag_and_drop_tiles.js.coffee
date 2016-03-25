String.prototype.times = (n) ->
  Array.prototype.join.call({length:n+1}, this)

window.dragAndDropProperties =
  items: ".tile_container:not(.placeholder_container)"
  connectWith: ".manage_section"
  cancel: ".placeholder_container, .no_tiles_section"
  revert: true
  tolerance: "pointer"
  placeholder: "tile_container"
  handle: ".tile-wrapper"

window.dragAndDropTiles = ->
  $("#draft").droppable({ 
    accept: ".tile_container",
    out: (event, ui) ->
      showDraftBlockedOverlay false
    over: (event, ui) ->
      if $( "#draft" ).sortable( "option", "disabled" )
        showDraftBlockedOverlay true
  })

  dragAndDropTilesEvents =
    update: (event, ui) ->
      #console.log("update")
      section = $(this)
      tile = ui.item
      $.when(window.moveConfirmation).then ->
        updateEvent(event, tile, section)
      
    over: (event, ui) ->
      #console.log("over")
      section = $(this)
      tile = ui.item
      overEvent(event, tile, section)
      
    start: (event, ui) ->
      #console.log("start")
      section = $(this)
      tile = ui.item
      startEvent(event, tile, section)
      
    receive: (event, ui) ->
      #console.log("receive")
      section = $(this)
      tile = ui.item
      receiveEvent(event, tile, section)
      
    stop: (event, ui) ->
      #console.log("stop")
      section = $(this)
      tile = ui.item
      $.when(window.moveConfirmation).then ->
        stopEvent(event, tile, section)
      , ->
        cancelTileMoving()
        updateTilesAndPlaceholdersAppearance()
      
      
  window.tileSortable = $( "#draft, #active, #archive" ).sortable( 
    $.extend(window.dragAndDropProperties, dragAndDropTilesEvents)
  ).disableSelection()

  updateEvent = (event, tile, section) ->
    # if user moves tile from one section to another then
    # update is called first for source section, then for destination section.
    # so we need to save name of the source and then use it in ajax call
    if isTileInSection tile, section
      tileInfo tile, "remove"
      saveTilePosition tile
    else # is executed if tile leaves section
      window.sourceSectionName = section.attr("id")

  overEvent = (event, tile, section) ->
    updateTilesAndPlaceholdersAppearance()
    updateTileInSectionClass(tile, section)

  startEvent = (event, tile, section) ->
    resetGloballVariables()
    turnOnDraftBlocking tile, section
    showDraftBlockedMess false
    tileInfo tile, "hide"

  receiveEvent = (event, tile, section) ->
    if completedTileWasAttemptedToBeMovedInBlockedDraft()
      cancelTileMoving()
    else if isTileMoved(tile, "archive", "active") && tileCompletionsNum(tile) > 0
      moveComfirmationModal()
      

  stopEvent = (event, tile, section) ->
    turnOffDraftBlocking tile, section
    if completedTileWasAttemptedToBeMovedInBlockedDraft()
      showDraftBlockedMess true, section
      showDraftBlockedOverlay false
    updateTilesAndPlaceholdersAppearance()
    tileInfo tile, "show"

  numberInRow = (section) ->
    if section == "draft" || section == "suggestion_box"
      6
    else
      4

  placeholderSelector = ->
    ".tile_container.placeholder_container:not(.hidden_tile)"

  notDraggedTileSelector = ->
    ".tile_container:not(.ui-sortable-helper):not(.hidden_tile)"

  placeholderHTML = ->
    '<div class="tile_container placeholder_container">' +
      '<div class="tile_thumbnail placeholder_tile"></div>' +
    '</div>'

  sectionNames = ->
    ["draft", "active", "archive", "suggestion_box"]

  findTileId = (tile) ->
    tile.find(".tile_thumbnail").data("tile-id")

  getTilesSection = (tile) ->
    tile.closest(".manage_section").attr("id")

  updateTileInSectionClass = (tile, section) ->
    tile.removeClass("tile_in_draft")
        .removeClass("tile_in_active")
        .removeClass("tile_in_archive")
        .addClass("tile_in_" + section.attr("id"))

  updateTilesAndPlaceholdersAppearance = ->
    updateAllPlaceholders()
    updateAllNoTilesSections()
    updateTileVisibility()

  window.updateTilesAndPlaceholdersAppearance = updateTilesAndPlaceholdersAppearance

  updateAllPlaceholders = ->
    for section in sectionNames()
      updatePlaceholders section

  updatePlaceholders = (section) ->
    allTilesNumber = $("#" + section).find( notDraggedTileSelector() ).length
    placeholdersNumber = $("#" + section).find( placeholderSelector() ).length
    tilesNumber =  allTilesNumber - placeholdersNumber
    expectedPlaceholdersNumber = ( numberInRow(section) - ( tilesNumber % numberInRow(section) ) ) % numberInRow(section)
    removePlaceholders(section)
    addPlaceholders(section, expectedPlaceholdersNumber)

  removePlaceholders = (section) ->
    $("#" + section).children( placeholderSelector() ).remove()

  addPlaceholders = (section, number) ->
    $("#" + section).append placeholderHTML().times(number) 

  updateAllNoTilesSections = ->
    for section in sectionNames()
      updateNoTilesSection section

  updateNoTilesSection = (section) ->
    no_tiles_section = $("#" + section).find(".no_tiles_section")
    if $("#" + section).children( notDraggedTileSelector() ).length == 0
      no_tiles_section.show()
    else
      no_tiles_section.hide()

  tileInfo = (tile, action) ->
    controlElements = tile.find(".tile_buttons, .tile_stats")
    shadowOverlay = tile.find(".shadow_overlay")
    if action == "show"
      controlElements.css("display", "")
      shadowOverlay.css("opacity", "")
    else if action == "hide"
      controlElements.hide()
      shadowOverlay.css("opacity", "0")
    else if action == "remove"
      controlElements.remove()

  saveTilePosition = (tile) ->
    id = findTileId tile
    left_tile_id = findTileId tile.prev()
    right_tile_id = findTileId tile.next()
    status = getTilesSection tile

    $.ajax({
      data: {
        left_tile_id: left_tile_id, 
        right_tile_id: right_tile_id,
        status: status,
        source_section: sourceSectionParams()
      },
      type: 'POST',
      url: '/client_admin/tiles/' + id + '/sort'
      success: ->
        updateTileVisibility()
        Airbo.TileThumbnail.initTile(id)
    });

  sourceSectionParams = ->
    if window.sourceSectionName
      section = $("#" + window.sourceSectionName)
      window.sourceSectionName = null

      sectionParams(section)
    else
      null

  sectionParams = (section) ->
    name = section.attr("id")
    tiles = section.find(".tile_thumbnail:not(.placeholder_tile)")
    presented_ids = ($(tile).data("tile-id") for tile in tiles)
    {name: name, presented_ids: presented_ids}

  tileCompletionsNum = (tile) ->
    parseInt tile.find(".completions").text().match(/\d+/)?[0]

  turnOnDraftBlocking = (tile, section) ->
    status = getTilesSection tile
    completions = tileCompletionsNum(tile)
    if status != "draft" && completions > 0
      $("#draft").sortable("disable")
      section.sortable("refresh")

  turnOffDraftBlocking = (tile, section) ->
    $("#draft").sortable("enable")
    section.sortable("refresh")

  updateTileVisibility = ->
    for section in sectionNames()
      updateTileVisibilityIn section

  draftSectionIsCompressed = ->
    $("#draft_tiles").hasClass "compressed_section"

  visibleTilesNumberIn = (section) ->
    if section == "draft" || section == "suggestion_box"
      if draftSectionIsCompressed()
        numberInRow(section)
      else
        9999
    else if section == "archive"
      numberInRow(section)
    else
      9999

  updateTileVisibilityIn = (section) ->
    tiles = $("#" + section).find( "> " + notDraggedTileSelector() )
    visibleTilesNumber = visibleTilesNumberIn(section)
    for tile, index in tiles
      if index < visibleTilesNumber
        $(tile).css("display", "block")
      else
        $(tile).css("display", "none")

  window.updateTileVisibilityIn = updateTileVisibilityIn

  showDraftBlockedOverlay = (isOn) ->
    if isOn
      $(".draft_overlay").show()
    else
      $(".draft_overlay").hide()

  isDraftBlockedOverlayShowed = ->
    $(".draft_overlay").css("display") == "block"

  completedTileWasAttemptedToBeMovedInBlockedDraft = ->
    isDraftBlockedOverlayShowed()

  showDraftBlockedMess = (isOn, section) ->
    if isOn
      mess_div = section.closest(".manage_tiles").find(".draft_blocked_message")
      mess_div.show()
      unless iOSdevice()
        $('html, body').scrollTo(mess_div, {duration: 500})
    else
      $(".draft_blocked_message").hide()

  iOSdevice = ->
    navigator.userAgent.match(/(iPad|iPhone|iPod)/g)

  isTileInSection = (tile, section) ->
    getTilesSection(tile) == section.attr("id")

  cancelTileMoving = ->
    if window.sourceSectionName
      $("#" + window.sourceSectionName).sortable( "cancel" ).sortable( "refresh" )

  moveComfirmationModal = ->
    window.moveConfirmationDeferred = $.Deferred()
    window.moveConfirmation = window.moveConfirmationDeferred.promise()
    $(".move-tile-confirm").foundation('reveal', 'open')

  isTileMoved = (tile, fromSectionName, toSectionName) ->
    getTilesSection(tile) == toSectionName &&
    window.sourceSectionName == fromSectionName

  resetGloballVariables = ->
    window.sourceSectionName = null
    window.moveConfirmationDeferred = null
    window.moveConfirmation = null
