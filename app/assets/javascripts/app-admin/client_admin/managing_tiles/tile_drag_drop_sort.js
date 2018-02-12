var Airbo = window.Airbo || {};

Airbo.TileDragDropSort = (function() {
  var allowRedigest;
  var sourceSectionName,
    placeholderSelector =
      ".tile_container.placeholder_container:not(.hidden_tile)",
    notDraggedTileSelector =
      ".tile_container:not(.ui-sortable-helper):not(.hidden_tile)",
    sectionNames = ["draft", "active", "archive", "suggestion_box"],
    placeholderHTML =
      '<div class="tile_container placeholder_container">' +
      '<div class="tile_thumbnail placeholder_tile"></div>' +
      "</div>",
    moveConfirmationDeferred,
    moveConfirmation;

  var sortableConfig = {
    items: ".tile_container:not(.placeholder_container)",
    connectWith: ".manage_section",
    cancel: ".placeholder_container, .no_tiles_section",
    revert: true,
    tolerance: "pointer",
    placeholder: "tile_container",
    handle: ".tile-wrapper",

    update: function(event, ui) {
      var section, tile;
      section = $(this);
      tile = ui.item;
      return $.when(moveConfirmation).then(function() {
        return updateEvent(event, tile, section);
      });
    },

    start: function(event, ui) {
      var section, tile;
      section = $(this);
      tile = ui.item;
      return startEvent(event, tile, section);
    },

    receive: function(event, ui) {
      return;
    }
  };

  function initTileSorting() {
    $("#draft, #active, #archive")
      .sortable(sortableConfig)
      .disableSelection();
  }

  function updateEvent(event, tile, section) {
    tileInfo(tile, "remove");
    saveTilePosition(tile);
  }

  function startEvent(event, tile, section) {
    disableActiveSorting(event, tile, section);
    tileInfo(tile, "hide");
  }

  function showDraftBlockedOverlay(isOn, node) {
    var overlay;
    if (isOn && node) {
      overlay = node.parents(".manage_tiles").children(".draft_overlay");
      overlay.show();
    } else {
      $(".draft_overlay").hide();
    }
  }

  function cancelTileMoving() {
    if (sourceSectionName) {
      return $("#" + sourceSectionName)
        .sortable("cancel")
        .sortable("refresh");
    }
  }

  function disableActiveSorting(event, tile, section) {
    if (tile.data("assemblyRequired") === true) {
      $("#active").sortable("disable");
      return section.sortable("refresh");
    }
  }

  function turnOffDraftBlocking(tile, section) {
    $("#draft").sortable("enable");
    section.sortable("refresh");
  }

  function numberInRow(section) {
    return 4;
  }

  function findTileId(tile) {
    return tile.find(".tile_thumbnail").data("tile-id");
  }

  function getTilesSection(tile) {
    return tile.closest(".manage_section").attr("id");
  }

  function tileInfo(tile, action) {
    var controlElements, shadowOverlay;
    controlElements = tile.find(".tile_buttons, .tile_stats");
    shadowOverlay = tile.find(".shadow_overlay");
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
    var newStatus = getTilesSection(tile);

    $.ajax({
      data: {
        sort: {
          left_tile_id: leftTileId,
          new_status: newStatus,
          redigest: allowRedigest
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

  function moveComfirmationModal(tile) {
    moveConfirmationDeferred = $.Deferred();
    moveConfirmation = moveConfirmationDeferred.promise();
    confirmReposting(tile);
  }

  function confirmReposting(tile) {
    var checkConfirm = function(isConfirm) {
      if (isConfirm) {
        allowRedigest = $(".sweet-alert input#digestable").is(":checked");
        moveConfirmationDeferred.resolve();
      } else {
        tileInfo(tile, "show");
        moveConfirmationDeferred.reject();
      }
    };
    Airbo.TileAction.confirmUnarchive(checkConfirm);
  }

  function isTileMoved(tile, fromSectionName, toSectionName) {
    return (
      getTilesSection(tile) === toSectionName &&
      sourceSectionName === fromSectionName
    );
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
