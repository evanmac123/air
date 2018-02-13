var Airbo = window.Airbo || {};

Airbo.TileDragDropSort = (function() {
  var sortableConfig = {
    items: ".tile_container:not(.placeholder_container)",
    connectWith: ".manage_section",
    cancel: ".placeholder_container, .no_tiles_section",
    revert: true,
    tolerance: "pointer",
    placeholder: "tile_container",
    handle: ".tile-wrapper",

    start: function(event, ui) {
      var section = $(this);
      var tile = ui.item;
      return startEvent(event, tile, section);
    },

    update: function(event, ui) {
      var section = $(this);
      var tile = ui.item;
      return updateEvent(event, tile, section);
    }
  };

  function initTileSorting() {
    $("#draft, #active, #archive")
      .sortable(sortableConfig)
      .disableSelection();
  }

  function updateEvent(event, tile) {
    tileInfo(tile, "remove");
    saveTilePosition(tile);
  }

  function startEvent(event, tile, section) {
    disableActiveSorting(event, tile, section);
    tileInfo(tile, "hide");
  }

  function disableActiveSorting(event, tile, section) {
    if (tile.data("assemblyRequired") === true) {
      $("#active").sortable("disable");
      return section.sortable("refresh");
    }
  }

  function findTileId(tile) {
    return tile.find(".tile_thumbnail").data("tile-id");
  }

  function tileInfo(tile, action) {
    var controlElements = tile.find(".tile_buttons, .tile_stats");
    var shadowOverlay = tile.find(".shadow_overlay");

    if (action === "show") {
      controlElements.css("display", "");
      shadowOverlay.css("opacity", "");
    } else if (action === "hide") {
      controlElements.hide();
      shadowOverlay.css("opacity", "0");
    } else if (action === "remove") {
      controlElements.remove();
    }
  }

  function replaceMovedTile(tile, updatedTileContainer) {
    tile.replaceWith(updatedTileContainer);
    Airbo.TileThumbnailMenu.initMoreBtn(tile.find(".pill.more"));
  }

  function onSortSuccess(tile, result) {
    replaceMovedTile(tile, result.tileHTML);
  }

  function saveTilePosition(tile) {
    var id = findTileId(tile);
    var leftTileId = findTileId(tile.prev());

    $.ajax({
      data: {
        sort: {
          left_tile_id: leftTileId || null
        }
      },
      type: "POST",
      url: "/api/client_admin/tiles/" + id + "/sorts",
      success: function(result) {
        onSortSuccess(tile, result);
      }
    });
  }

  function sectionParams(section) {
    var name, presented_ids, tile, tiles;
    name = section.attr("id");
    tiles = section.find(".tile_thumbnail:not(.placeholder_tile)");
    presented_ids = (function() {
      var i, len, results;
      results = [];
      for (i = 0, len = tiles.length; i < len; i++) {
        tile = tiles[i];
        results.push($(tile).data("tile-id"));
      }
      return results;
    })();
    return {
      name: name,
      presented_ids: presented_ids
    };
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
