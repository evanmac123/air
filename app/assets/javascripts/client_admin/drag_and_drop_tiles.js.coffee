String.prototype.times = (n) ->
  Array.prototype.join.call({length:n+1}, this)

window.dragAndDropTiles = ->
  $( "#draft" ).sortable({ connectWith: ".draft-active" })
  $( "#active" ).sortable({ connectWith: ".draft-active, .active-archive" })
  $( "#archive" ).sortable({ connectWith: ".active-archive" })
  $( "#draft, #active, #archive" ).sortable({
    items: ".tile_container:not(.placeholder_container)",
    revert: true,
    update: (event, ui) ->
      id = ui.item.find(".tile_thumbnail").data("tile_id")
      left_tile_id = ui.item.prev().find(".tile_thumbnail").data("tile_id")
      right_tile_id = ui.item.next().find(".tile_thumbnail").data("tile_id")
      status = ui.item.closest(".manage_section").attr("id")
      $.ajax({
        data: {
          left_tile_id: left_tile_id, 
          right_tile_id: right_tile_id,
          status: status
        },
        type: 'POST',
        url: '/client_admin/tiles/' + id + '/sort'
      });
    over: (event, ui) ->
      updateAllPlaceholders()
      updateAllNoTilesMess()
    out: (event, ui) ->
      updateAllPlaceholders()
      updateAllNoTilesMess()
    start: (event, ui) ->
      status = ui.item.closest(".manage_section").attr("id")
      completions = ui.item.find(".completions a").text()
      if status == "active" && completions != "0 users"
        $(".draft_overlay").show()
        $("#draft").sortable("disable")
        $(this).sortable("refresh")
    stop: (event, ui) ->
      $(".draft_overlay").hide()
      $("#draft").sortable("enable")
      $(this).sortable("refresh")
  }).disableSelection();

  numberInRow = ->
    4

  placehoderSelector = ->
    ".tile_container.placeholder_container:not(.creation_placeholder)"

  placeholderHTML = ->
    '<div class="tile_container placeholder_container">' +
      '<div class="tile_thumbnail placeholder_tile"></div>' +
    '</div>'

  updateAllPlaceholders = ->
    updatePlaceholders("draft")
    updatePlaceholders("active")
    updatePlaceholders("archive")

  updatePlaceholders = (section) ->
    allTilesNumber = $("#" + section).find(".tile_container").length
    placeholdersNumber = $("#" + section).find( placehoderSelector() ).length
    tilesNumber =  allTilesNumber - placeholdersNumber
    expectedPlaceholdersNumber = ( numberInRow() - ( tilesNumber % numberInRow() ) ) % numberInRow()
    addOrRemovePlaceholders(section, expectedPlaceholdersNumber - placeholdersNumber)

  addOrRemovePlaceholders = (section, number) ->
    if number > 0       # add
      $("#" + section).append placeholderHTML().times(number) 
    else if number < 0  # remove
      $("#" + section).find( placehoderSelector() + ":gt(" + (number - 1) + ")" ).remove()

  updateAllNoTilesMess = ->
    updateNoTilesMess("draft")
    updateNoTilesMess("active")
    updateNoTilesMess("active")

  updateNoTilesMess = (section) ->
    message = $("#" + section).find(".no_tiles_message")
    if $("#" + section).find(".tile_container").length == 0
      message.show()
    else
      message.hide()