/*-----------------    drag_drop_sorting.js  ------------------------------------------------------------------------------------------------------------------*/

replaceMovedTile = function(tile_id, updated_tile_container) {
  //TODO  reference tile container directly instead of going through single tile
  var tile = $("#single-tile-" + tile_id).closest(".tile_container");
  tile.replaceWith(updated_tile_container);
  tile = $("#single-tile-" + tile_id).closest(".tile_container");
  Airbo.TileThumbnailMenu.initMoreBtn(tile.find(".pill.more"));
};

showMoreDraftTiles = function() {
  var draftTilesCount = notTilePlaceholdersInSection($("#draft")).length;
  return draftTilesCount > 6 && selectedSection() === "draft";
};

selectedSection = function() {
  if ($("#draft_tiles.draft_selected").length > 0) {
    return "draft";
  } else {
    return "box";
  }
};

fillInLastTile = function(tile_id, section_name, tile_container) {
  var section = $("#" + section_name);
  if (sectionHasFreePlace(section) && tileIsNotPresent(tile_id)) {
    addTileOnFreePlace(section, tile_container);
  }
};

addTileOnFreePlace = function(section, tile_container) {
  var free_place = freePlaceForTile(section);
  free_place.removeClass("placeholder_container").replaceWith(tile_container);
};

freePlaceForTile = function(section) {
  var free_place = $(tilePlaceholdersInSection(section)[0]);
  if (free_place.length === 0) {
    free_place = $('<div class="tile_container"></div>');
    section.append(free_place);
  }
  return free_place;
};

tileIsNotPresent = function(tile_id) {
  return !tileIsPresent(tile_id);
};

tileIsPresent = function(tile_id) {
  return $("#single-tile-" + tile_id).length > 0;
};

sectionHasFreePlace = function(section) {
  return !sectionIsFull(section);
};

sectionIsFull = function(section) {
  var tileNum = Airbo.TilePlaceHolderManager.visibleTilesNumberIn(section);
  return notTilePlaceholdersInSection(section).length >= tileNum;
};

notTilePlaceholdersInSection = function(section) {
  return section.children(notTilePlaceholderSelector());
};

tilePlaceholdersInSection = function(section) {
  return section.children(tilePlaceholderSelector());
};

notTilePlaceholderSelector = function() {
  return ".tile_container:not(.placeholder_container)";
};

tilePlaceholderSelector = function() {
  return ".tile_container.placeholder_container";
};

/*-----------------    tile_drag_drop_sort.js  ------------------------------------------------------------------------------------------------------------------*/
var Airbo = window.Airbo || {};

var allowRedigest;

Airbo.TileDragDropSort = (function() {
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

    over: function(event, ui) {
      var section, tile;
      section = $(this);
      tile = ui.item;
      return overEvent(event, tile, section);
    },

    start: function(event, ui) {
      var section, tile;
      section = $(this);
      tile = ui.item;
      return startEvent(event, tile, section);
    },

    receive: function(event, ui) {
      var section, tile;
      section = $(this);
      tile = ui.item;
      return receiveEvent(event, tile, section);
    },

    stop: function(event, ui) {
      var section, tile;
      section = $(this);
      tile = ui.item;
      return $.when(moveConfirmation).then(
        function() {
          return stopEvent(event, tile, section);
        },
        function() {
          cancelTileMoving();
          return Airbo.TilePlaceHolderManager.updateTilesAndPlaceholdersAppearance();
        }
      );
    }
  };

  function initDraftDroppable() {
    $("#draft").droppable({
      accept: ".tile_container",
      over: function(event, ui) {
        if ($("#draft").sortable("option", "disabled")) {
          showDraftBlockedOverlay(true, $("#draft"));
          Airbo.Utils.alert(
            "You may not move tiles that have already been completed back to drafts"
          );
        }
      }
    });
  }

  function initActiveDroppable() {
    $("#active").droppable({
      accept: ".tile_container",
      over: function(event, ui) {
        if ($("#active").sortable("option", "disabled")) {
          showDraftBlockedOverlay(true, $("#active"));
          Airbo.Utils.alert(Airbo.Utils.Messages.incompleteTile);
        }
      }
    });
  }

  function initTileSorting() {
    $("#draft, #active, #archive")
      .sortable(sortableConfig)
      .disableSelection();
  }

  function updateEvent(event, tile, section) {
    if (isTileInSection(tile, section)) {
      tileInfo(tile, "remove");
      saveTilePosition(tile);
    } else {
      sourceSectionName = section.attr("id");
    }
  }

  function overEvent(event, tile, section) {
    Airbo.TilePlaceHolderManager.updateTilesAndPlaceholdersAppearance();
    updateTileInSectionClass(tile, section);
  }

  function startEvent(event, tile, section) {
    turnOnDraftBlocking(tile, section);
    disableActiveSorting(event, tile, section);
    tileInfo(tile, "hide");
  }

  function receiveEvent(event, tile, section) {
    var id;
    if (isDraftBlockedOverlayShowed()) {
      cancelTileMoving();
    } else if (
      isTileMoved(tile, "archive", "active") &&
      tileCompletionsNum(tile) > 0
    ) {
      moveComfirmationModal(tile);
    } else if (isTileMoved(tile, "draft", "active")) {
      id = findTileId(tile);
      Airbo.TileAction.movePing(tile, "active", "Dragged tile to move");
    }
  }

  function stopEvent(event, tile, section) {
    $("#active").sortable("enable");
    turnOffDraftBlocking(tile, section);
    showDraftBlockedOverlay(false);
    Airbo.TilePlaceHolderManager.updateTilesAndPlaceholdersAppearance();
    tileInfo(tile, "show");
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

  function isDraftBlockedOverlayShowed() {
    return $(".draft_overlay").css("display") === "block";
  }

  function isTileInSection(tile, section) {
    return getTilesSection(tile) === section.attr("id");
  }

  function cancelTileMoving() {
    if (sourceSectionName) {
      return $("#" + sourceSectionName)
        .sortable("cancel")
        .sortable("refresh");
    }
  }

  function turnOnDraftBlocking(tile, section) {
    var completions, status;
    status = getTilesSection(tile);
    completions = tileCompletionsNum(tile);
    if (status !== "draft" && completions > 0) {
      $("#draft").sortable("disable");
      return section.sortable("refresh");
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

  function updateTileInSectionClass(tile, section) {
    tile
      .removeClass("tile_in_draft")
      .removeClass("tile_in_active")
      .removeClass("tile_in_archive")
      .addClass("tile_in_" + section.attr("id"));
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

  function onSortSuccess(result) {
    replaceMovedTile(result.tileId, result.tileHTML);

    Airbo.PubSub.publish("updateShareTabNotification", {
      number: result.tilesToBeSentCount
    });
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
        onSortSuccess(result);
        Airbo.TilePlaceHolderManager.updateTileVisibility();
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

  function tileCompletionsNum(tile) {
    var ref;
    return parseInt(
      (ref = tile
        .find(".completions")
        .text()
        .match(/\d+/)) != null
        ? ref[0]
        : void 0
    );
  }

  function draftSectionIsCompressed() {
    return $("#draft_tiles").hasClass("compressed_section");
  }

  function visibleTilesNumberIn(section) {
    if (section === "draft" || section === "suggestion_box") {
      if (draftSectionIsCompressed()) {
        return numberInRow(section);
      } else {
        return 9999;
      }
    } else if (section === "archive") {
      return numberInRow(section);
    } else {
      return 9999;
    }
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
    initDraftDroppable();
    initActiveDroppable();
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent(".js-ca-tiles-index-module")) {
    Airbo.TileDragDropSort.init();
    Airbo.DraftSectionExpander.init();
  }
});
