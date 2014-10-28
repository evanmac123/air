String.prototype.times = (n) ->
  Array.prototype.join.call({length:n+1}, this)

window.dragAndDropTiles = ->
  $("#draft").droppable({ 
    accept: ".tile_container",
    ###
    activate: (event, ui) ->
      console.log("drop-activate" + $(this).attr("id"))
    create: (event, ui) ->
      console.log("drop-create" + $(this).attr("id"))
    deactivate: (event, ui) ->
      console.log("drop-deactivate" + $(this).attr("id"))
    drop: (event, ui) ->
      console.log("drop-drop" + $(this).attr("id"))
    ###
    out: (event, ui) ->
      #console.log("drop-out" + $(this).attr("id"))
      showDraftBlockedOverlay false
    over: (event, ui) ->
      #console.log("drop-over" + $(this).attr("id"))
      if $( "#draft" ).sortable( "option", "disabled" )
        showDraftBlockedOverlay true
  })
  $( "#draft, #active, #archive" ).sortable({
    items: ".tile_container:not(.placeholder_container)",
    connectWith: ".manage_section",
    cancel: ".placeholder_container, .no_tiles_section",
    revert: true,
    tolerance: "pointer",
    placeholder: "tile_container",
    update: (event, ui) ->
      tile = ui.item
      # update is called on every changed section so we don't want multiple ajax calls
      if getTilesSection(tile) == $(this).attr("id")
        #console.log("update" + $(this).attr("id"))
        removeTileStats tile, $(this)
        saveTilePosition tile, $(this)
    over: (event, ui) ->
      #console.log("over" + $(this).id)
      updateAllPlaceholders()
      updateAllNoTilesSections()
      updateTileVisibility()
    #out: (event, ui) ->
    #  updateAllNoTilesSections()
    start: (event, ui) ->
      #console.log("start" + $(this).attr("id"))
      turnOnDraftBlocking ui.item, $(this)
      showDraftBlockedMess false
    stop: (event, ui) ->
      console.log("stop" + $(this).attr("id"))
      turnOffDraftBlocking ui.item, $(this)
      showDraftBlockedMess $(".draft_overlay").css("display") == "block", $(this)
      showDraftBlockedOverlay false
    ###
    receive: (event, ui) ->
      console.log("receive" + $(this).attr("id"))
      #cancelIfDraftBlocked ui.item, $(this)
      #$( "#draft, #active, #archive" ).sortable( "cancel" )
      #$( "#draft, #active, #archive" ).sortable("refresh")
    activate: (event, ui) ->
      console.log("activate" + $(this).attr("id"))
    beforeStop: (event, ui) ->
      console.log("beforeStop" + $(this).attr("id"))
    change: (event, ui) ->
      console.log("change" + $(this).attr("id"))
      #$( "#draft" ).sortable( "disable" )
      #$( "#draft, #active, #archive" ).sortable("refresh")
    create: (event, ui) ->
      console.log("create" + $(this).attr("id"))
    deactivate: (event, ui) ->
      console.log("deactivate" + $(this).attr("id"))
    out: (event, ui) ->
      console.log("out" + $(this).attr("id"))
    remove: (event, ui) ->
      console.log("remove" + $(this).attr("id"))
    sort: (event, ui) ->
      console.log("sort" + $(this).attr("id"))
    ###
  }).disableSelection()

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

  saveTilePosition = (tile, source_section) ->
    id = findTileId tile
    left_tile_id = findTileId tile.prev()
    right_tile_id = findTileId tile.next()
    status = getTilesSection tile

    $.ajax({
      data: {
        left_tile_id: left_tile_id, 
        right_tile_id: right_tile_id,
        status: status,
        source_section: sectionParams(source_section)
      },
      type: 'POST',
      url: '/client_admin/tiles/' + id + '/sort',
      beforeSend: ->
        console.log(id)
      success: ->
        updateTileVisibility()
    });

  sectionParams = (section) ->
    name = section.attr("id")
    tiles = section.find(".tile_thumbnail:not(.placeholder_tile)")
    presented_ids = ($(tile).data("tile_id") for tile in tiles)
    {name: name, presented_ids: presented_ids}

  turnOnDraftBlocking = (tile, section) ->
    status = getTilesSection tile
    completions = tile.find(".completions a").text()
    if status != "draft" && completions != "0 users"
      #$("#active, #archive").sortable("option", "containment", ".completed_tiles_containment")
      #$("#active, #archive").sortable("refresh")
      #$(".draft_overlay").show()
      $("#draft").sortable("disable")
      section.sortable("refresh")

  turnOffDraftBlocking = (tile, section) ->
    #$(".draft_overlay").hide()
    $("#draft").sortable("enable")
    section.sortable("refresh")

  updateTileVisibility = ->
    updateTileVisibilityIn "draft"
    updateTileVisibilityIn "archive"

  updateTileVisibilityIn = (section) ->
    tiles = $("#" + section).find( "> " + notDraggedTileSelector() )
    for tile, index in tiles
      if index < 8
        $(tile).css("display", "block")
      else
        $(tile).css("display", "none")
  ###
  cancelIfDraftBlocked = (tile, section) ->
    completions = tile.find(".completions a").text()
    if completions.length > 0 && completions != "0 users" && section.attr("id") == "draft"
      $( "#draft, #active, #archive" ).sortable("cancel").sortable("refresh")
    false
  ###
  showDraftBlockedOverlay = (isOn) ->
    if isOn
      $(".draft_overlay").show()
    else
      $(".draft_overlay").hide()

  showDraftBlockedMess = (isOn, section) ->
    if isOn
      section.closest(".manage_tiles").find(".draft_blocked_message").show()
    else
      $(".draft_blocked_message").hide()