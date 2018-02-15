var Airbo = window.Airbo || {};

Airbo.TileDragDropSort = (function() {
  function initTileSorting() {
    var $sortableSections = $("#plan, #draft, #active, #archive");

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
    toggleTileControls(tile);
    saveTilePosition(tile);
  }

  function startEvent(event, tile) {
    toggleTileControls(tile);
  }

  function findTileId(tile) {
    return tile.find(".tile_thumbnail").data("tile-id");
  }

  function toggleTileControls(tile) {
    var controlElements = tile.find(".tile_buttons, .tile_stats");
    var shadowOverlay = tile.find(".shadow_overlay");

    controlElements.toggle();
    shadowOverlay.toggle();
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
        return;
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
