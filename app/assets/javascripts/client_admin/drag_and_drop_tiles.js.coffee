window.dragAndDropTiles = ->
  $( "#draft, #active, #archive" ).sortable({
    connectWith: ".manage_section",
    items: ".tile_container:not(.placeholder_container)",
    update: (event, ui) ->
      id = ui.item.find(".tile_thumbnail").data("tile_id")
      left_tile_id = ui.item.prev().find(".tile_thumbnail").data("tile_id")
      right_tile_id = ui.item.next().find(".tile_thumbnail").data("tile_id")

      $.ajax({
        data: {left_tile_id: left_tile_id, right_tile_id: right_tile_id},
        type: 'POST',
        url: '/client_admin/tiles/' + id + '/sort'
      });
  }).disableSelection();