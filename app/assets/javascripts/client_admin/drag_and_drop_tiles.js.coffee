String.prototype.times = (n) ->
  Array.prototype.join.call({length:n+1}, this)

window.dragAndDropProperties =
  items: ".tile_container:not(.placeholder_container)",
  connectWith: ".manage_section",
  cancel: ".placeholder_container, .no_tiles_section",
  revert: true,
  tolerance: "pointer",
  placeholder: "tile_container"

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
      tile = ui.item
      # if user moves tile from one section to another then
      # update is called first for source section, then for destination section.
      # so we need to save name of the source and then use it in ajax call
      if isTileInSection tile, $(this)
        saveTilePosition tile
      else
        window.sourceSectionName = $(this).attr("id")
        removeTileStats tile, $(this)
    over: (event, ui) ->
      updateTilesAndPlaceholdersAppearance()
    start: (event, ui) ->
      turnOnDraftBlocking ui.item, $(this)
      showDraftBlockedMess false
    receive: (event, ui) ->
      if completedTileWasAttemptedToBeMovedInBlockedDraft()
        cancelTileMoving()
    stop: (event, ui) ->
      turnOffDraftBlocking ui.item, $(this)
      if completedTileWasAttemptedToBeMovedInBlockedDraft()
        showDraftBlockedMess true, $(this)
        showDraftBlockedOverlay false
      updateTilesAndPlaceholdersAppearance()
      
  $( "#draft, #active, #archive" ).sortable( 
    $.extend(window.dragAndDropProperties, dragAndDropTilesEvents)
  ).disableSelection()

  numberInRow = ->
    4

  placehoderSelector = ->
    ".tile_container.placeholder_container:not(.creation_placeholder)"

  notDraggedTileSelector = ->
    ".tile_container:not(.ui-sortable-helper)"

  placeholderHTML = ->
    '<div class="tile_container placeholder_container">' +
      '<div class="tile_thumbnail placeholder_tile"></div>' +
    '</div>'

  sectionNames = ->
    ["draft", "active", "archive"]

  findTileId = (tile) ->
    tile.find(".tile_thumbnail").data("tile_id")

  getTilesSection = (tile) ->
    tile.closest(".manage_section").attr("id")

  updateTilesAndPlaceholdersAppearance = ->
    updateAllPlaceholders()
    updateAllNoTilesSections()
    updateTileVisibility()

  updateAllPlaceholders = ->
    for section in sectionNames()
      updatePlaceholders section

  updatePlaceholders = (section) ->
    allTilesNumber = $("#" + section).find( notDraggedTileSelector() ).length
    placeholdersNumber = $("#" + section).find( placehoderSelector() ).length
    tilesNumber =  allTilesNumber - placeholdersNumber
    expectedPlaceholdersNumber = ( numberInRow() - ( tilesNumber % numberInRow() ) ) % numberInRow()
    removePlaceholders(section)
    addPlaceholders(section, expectedPlaceholdersNumber)

  removePlaceholders = (section) ->
    $("#" + section).children( placehoderSelector() ).remove()

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

  removeTileStats = (tile, source_section) ->
    destination_name = getTilesSection tile
    source_name = source_section.attr("id")

    if source_name != "draft" && destination_name == "draft"
      tile.find(".tile_stats").hide()

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
    presented_ids = ($(tile).data("tile_id") for tile in tiles)
    {name: name, presented_ids: presented_ids}

  turnOnDraftBlocking = (tile, section) ->
    status = getTilesSection tile
    completions = tile.find(".completions a").text()
    if status != "draft" && completions != "0 users"
      $("#draft").sortable("disable")
      section.sortable("refresh")

  turnOffDraftBlocking = (tile, section) ->
    $("#draft").sortable("enable")
    section.sortable("refresh")

  updateTileVisibility = ->
    updateTileVisibilityIn "draft"
    updateTileVisibilityIn "archive"

  visibleTilesNumberIn = (section) ->
    if section == "draft"
      8
    else if section == "archive"
      4
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
    navigator.userAgent.match(/(iPad|iPhone|iPod)/g) ? true : false

  isTileInSection = (tile, section) ->
    getTilesSection(tile) == section.attr("id")

  cancelTileMoving = ->
    $(".manage_section").sortable( "cancel" ).sortable( "refresh" )