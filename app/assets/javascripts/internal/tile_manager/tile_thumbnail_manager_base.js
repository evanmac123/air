var Airbo = window.Airbo || {};

Airbo.TileThumbnailManagerBase = (function(){

  function getTileIdsInContainer(self) {
    var tiles = $(self).parents(".tile_container").siblings(".tile_container").andSelf();
    return $.makeArray(tiles).map(function(tile) {
      return $(tile).data("tile-container-id");
    });
  }

  return {
    getTileIdsInContainer: getTileIdsInContainer,
  };
}());
