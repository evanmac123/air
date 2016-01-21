window.dragAndDropInSection = ->
  $(".manage_section").sortable( 
    $.extend(window.dragAndDropProperties, {
      update: (event, ui) ->
        saveTilePosition ui.item
    })
  ).disableSelection()

  saveTilePosition = (tile) ->
    id = findTileId tile
    left_tile_id = findTileId tile.prev()
    right_tile_id = findTileId tile.next()

    $.ajax({
      data: {
        left_tile_id: left_tile_id, 
        right_tile_id: right_tile_id
      },
      type: 'POST',
      url: saveUrl(id)
    });

  findTileId = (tile) ->
    tile.find(".tile_thumbnail").data("tile-id")

  saveUrl = (id) ->
    section_name = $(".manage_section").attr("id")
    url_section_name = "inactive_tiles"
    '/client_admin/' + url_section_name + '/' + id + '/sort'
