String.prototype.times = (n) ->
  Array.prototype.join.call({length:n+1}, this)

window.dragAndDropTiles = ->
  $( "#draft, #active, #archive" ).sortable({
    items: ".tile_container:not(.placeholder_container)",
    connectWith: ".manage_section",
    cancel: ".placeholder_container, .no_tiles_section",
    revert: true,
    tolerance: "pointer",
    placeholder: "tile_container",
    update: (event, ui) ->
      removeTileStats ui.item, $(this)
      saveTilePosition ui.item
    over: (event, ui) ->
      updateAllPlaceholders()
      updateAllNoTilesSections()
    #out: (event, ui) ->
    #  updateAllNoTilesSections()
    start: (event, ui) ->
      turnOnDraftBlocking ui.item, $(this)
    stop: (event, ui) ->
      turnOffDraftBlocking ui.item, $(this)
  }).disableSelection();

  numberInRow = ->
    4

  placehoderSelector = ->
    ".tile_container.placeholder_container:not(.creation_placeholder)"

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
    allTilesNumber = $("#" + section).find(".tile_container:not(.ui-sortable-helper)").length
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
    if $("#" + section).children(".tile_container:not(.ui-sortable-helper)").length == 0
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
        status: status
      },
      type: 'POST',
      url: '/client_admin/tiles/' + id + '/sort'
    });

  turnOnDraftBlocking = (tile, section) ->
    status = getTilesSection tile
    completions = tile.find(".completions a").text()
    if status != "draft" && completions != "0 users"
      $(".draft_overlay").show()
      $("#draft").sortable("disable")
      section.sortable("refresh")

  turnOffDraftBlocking = (tile, section) ->
    $(".draft_overlay").hide()
    $("#draft").sortable("enable")
    section.sortable("refresh")