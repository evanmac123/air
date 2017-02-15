var Airbo = window.Airbo || {};

Airbo.TileThumbnailManagerBase = (function(){

  function getTileIdsInContainer(self) {
    var tiles = $(self).parents(".tile_container").siblings(".tile_container").andSelf();
    return $.makeArray(tiles).map(function(tile) {
      return $(tile).data("tile-container-id");
    });
  }

  function getNeighboringTileIdsInContainer(self) {
    var tile_container = $(self).parents(".tile_container");
    var previousTile;
    var nextTile;

    if (tile_container.prev().length > 0) {
      previousTile = tile_container.prev();
    } else {
      previousTile = tile_container.siblings().last();
    }

    if (tile_container.next().length > 0) {
      nextTile = tile_container.next();
    } else {
      nextTile = tile_container.siblings().first();
    }

    var tiles = [previousTile, tile_container, nextTile];
    return tiles.map(function(tile) {
      return $(tile).data("tile-container-id");
    });
  }

  return {
    getTileIdsInContainer: getTileIdsInContainer,
    getNeighboringTileIdsInContainer: getNeighboringTileIdsInContainer
  };
}());