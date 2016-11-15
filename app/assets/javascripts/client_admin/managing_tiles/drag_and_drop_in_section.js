window.dragAndDropInSection = function() {
  var findTileId, saveTilePosition, saveUrl;

  $(".manage_section").sortable($.extend(window.dragAndDropProperties, {
    update: function(event, ui) {
      return saveTilePosition(ui.item);
    }
  })).disableSelection();

  saveTilePosition = function(tile) {
    var id, left_tile_id, right_tile_id;

    id = findTileId(tile);
    left_tile_id = findTileId(tile.prev());
    right_tile_id = findTileId(tile.next());

    return $.ajax({
      data: {
        left_tile_id: left_tile_id,
        right_tile_id: right_tile_id
      },

      type: 'POST',
      url: saveUrl(id)
    });
  };

  findTileId = function(tile) {
    return tile.find(".tile_thumbnail").data("tile-id");
  };

  return saveUrl = function(id) {
    var section_name, url_section_name;
    section_name = $(".manage_section").attr("id");
    url_section_name = "inactive_tiles";
    return '/client_admin/' + url_section_name + '/' + id + '/sort';
  };
};
