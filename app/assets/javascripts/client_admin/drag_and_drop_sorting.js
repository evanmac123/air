replaceMovedTile = function(tile_id, updated_tile_container){
  $("#single-tile-" + tile_id).closest(".tile_container").replaceWith(updated_tile_container)
}