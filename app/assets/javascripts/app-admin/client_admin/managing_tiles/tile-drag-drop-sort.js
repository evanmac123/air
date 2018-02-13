var Airbo = window.Airbo || {};

Airbo.TileDragDropSort = (function() {
  function initTileSorting() {
    var $sortableSections = $("#draft, #active, #archive");

    $sortableSections.sortable({
      items: ".tile_container:not(.placeholder_container)",
      revert: true,
      tolerance: "pointer",
      start: function(event, ui) {
        var tile = ui.item;
        return startEvent(event, tile);
      },

      stop: function(event, ui) {
        var tile = ui.item;
        return updateEvent(event, tile);
      }
    });
  }

  function updateEvent(event, tile) {
    showTileControls(tile);
    saveTilePosition(tile);
  }

  function startEvent(event, tile) {
    hideTileControls(tile);
  }

  function findTileId(tile) {
    return tile.find(".tile_thumbnail").data("tile-id");
  }

  function hideTileControls(tile) {
    var controlElements = tile.find(".tile_buttons, .tile_stats");
    var shadowOverlay = tile.find(".shadow_overlay");

    controlElements.hide();
    shadowOverlay.css("opacity", "0");
  }

  function showTileControls(tile) {
    var controlElements = tile.find(".tile_buttons, .tile_stats");
    controlElements.show();
  }

  function replaceMovedTile(tile, updatedTileContainer) {
    tile.replaceWith(updatedTileContainer);
    Airbo.TileThumbnailMenu.initMoreBtn(tile.find(".pill.more"));
  }

  function saveTilePosition(tile) {
    var id = findTileId(tile);
    var leftTileId = findTileId(tile.prev()) || null;
    var data = {
      sort: {
        left_tile_id: leftTileId
      }
    };

    $.ajax({
      data: data,
      type: "POST",
      url: "/api/client_admin/tiles/" + id + "/sorts",
      success: function(result) {
        replaceMovedTile(tile, result.tileHTML);
      }
    });
  }

  function init() {
    initTileSorting();
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent(".js-ca-tiles-index-module")) {
    Airbo.TileDragDropSort.init();
  }
});
