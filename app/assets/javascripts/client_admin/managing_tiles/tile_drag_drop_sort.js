var Airbo = window.Airbo || {}
String.prototype.times = function(n) {
  return Array.prototype.join.call({
    length: n + 1
  }, this);
};
var allowRedigest = false;
Airbo.TileDragDropSort = (function(){
  var dragAndDropProperties = {
    items: ".tile_container:not(.placeholder_container)",
    connectWith: ".manage_section",
    cancel: ".placeholder_container, .no_tiles_section",
    revert: true,
    tolerance: "pointer",
    placeholder: "tile_container",
    handle: ".tile-wrapper"
  };

  dragAndDropTilesEvents = {
    update: function(event, ui) {
      var section, tile;
      section = $(this);
      tile = ui.item;
      return $.when(window.moveConfirmation).then(function() {
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
      return $.when(window.moveConfirmation).then(function() {
        return stopEvent(event, tile, section);
      }, function() {
        cancelTileMoving();
        return updateTilesAndPlaceholdersAppearance();
      });
    }
  };
  var sourceSectionName
    , placeholderSelector = ".tile_container.placeholder_container:not(.hidden_tile)"
    , notDraggedTileSelector = ".tile_container:not(.ui-sortable-helper):not(.hidden_tile)"
    , sectionNames = ["draft", "active", "archive", "suggestion_box"]
    , placeholderHTML = '<div class="tile_container placeholder_container">' + '<div class="tile_thumbnail placeholder_tile"></div>' + '</div>'



  function initDraftDroppable(){
    $("#draft").droppable({
      accept: ".tile_container",
      out: function(event, ui) {
        return showDraftBlockedOverlay(false);
      },
      over: function(event, ui) {
        if ($("#draft").sortable("option", "disabled")) {
          return showDraftBlockedOverlay(true);
        }
      }
    });
  }

  function initTileSorting(){
    var config = $.extend(dragAndDropProperties, dragAndDropTilesEvents)
    $("#draft, #active, #archive").sortable(config).disableSelection();
  }



  function  updateEvent(event, tile, section) {
    if (isTileInSection(tile, section)) {
      tileInfo(tile, "remove");
      saveTilePosition(tile);
    } else {
     sourceSectionName = section.attr("id");
    }
  }

  function  overEvent (event, tile, section) {
    updateTilesAndPlaceholdersAppearance();
    updateTileInSectionClass(tile, section);
  }

  function startEvent(event, tile, section) {
    resetGloballVariables();
    turnOnDraftBlocking(tile, section);
    showDraftBlockedMess(false);
    tileInfo(tile, "hide");
  }

  function receiveEvent(event, tile, section) {
    var id;
    if (isDraftBlockedOverlayShowed()) {
      cancelTileMoving();
    } else if (isTileMoved(tile, "archive", "active") && tileCompletionsNum(tile) > 0) {
      moveComfirmationModal(tile);
    } else if (isTileMoved(tile, "draft", "active")) {
      id = findTileId(tile);
      Airbo.TileAction.movePing(id, "active", "Dragged tile to move");
    }
  }

  function stopEvent(event, tile, section) {
    turnOffDraftBlocking(tile, section);
    if (isDraftBlockedOverlayShowed()) {
      showDraftBlockedMess(true, section);
      showDraftBlockedOverlay(false);
    }
    updateTilesAndPlaceholdersAppearance();
    tileInfo(tile, "show");
  }



  function numberInRow(section) {
    if (section === "draft" || section === "suggestion_box") {
      return 6;
    } else {
      return 4;
    }
  }

  function findTileId(tile) {
    return tile.find(".tile_thumbnail").data("tile-id");
  }

  function getTilesSection(tile) {
    return tile.closest(".manage_section").attr("id");
  }

  function updateTileInSectionClass(tile, section) {
    tile.removeClass("tile_in_draft").removeClass("tile_in_active").removeClass("tile_in_archive").addClass("tile_in_" + section.attr("id"));
  }

  function updateTilesAndPlaceholdersAppearance() {
    updateAllPlaceholders();
    updateAllNoTilesSections();
    updateTileVisibility();
  }

  function updateAllPlaceholders() {
    var i, len, ref, results, section;
    ref = sectionNames;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      section = ref[i];
      results.push(updatePlaceholders(section));
    }
    return results;
  }

  function updatePlaceholders(section) {
    var allTilesNumber, expectedPlaceholdersNumber, placeholdersNumber, tilesNumber;
    allTilesNumber = $("#" + section).find(notDraggedTileSelector).length;
    placeholdersNumber = $("#" + section).find(placeholderSelector).length;
    tilesNumber = allTilesNumber - placeholdersNumber;
    expectedPlaceholdersNumber = (numberInRow(section) - (tilesNumber % numberInRow(section))) % numberInRow(section);
    removePlaceholders(section);
    return addPlaceholders(section, expectedPlaceholdersNumber);
  }

  function removePlaceholders(section) {
    return $("#" + section).children(placeholderSelector).remove();
  }

  function addPlaceholders(section, number) {

     $("#" + section).append(placeholderHTML.times(number));
  }

  function updateAllNoTilesSections() {
    var i, len, ref, results, section;
    ref = sectionNames;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      section = ref[i];
      results.push(updateNoTilesSection(section));
    }
    return results;
  }

  function updateNoTilesSection(section) {
    var no_tiles_section;
    no_tiles_section = $("#" + section).find(".no_tiles_section");
    if ($("#" + section).children(notDraggedTileSelector).length === 0) {
      no_tiles_section.show();
    } else {
      no_tiles_section.hide();
    }
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

  function saveTilePosition(tile) {
    var id, left_tile_id, right_tile_id, status;
    id = findTileId(tile);
    left_tile_id = findTileId(tile.prev());
    right_tile_id = findTileId(tile.next());
    status = getTilesSection(tile);
     $.ajax({
      data: {
        left_tile_id: left_tile_id,
        right_tile_id: right_tile_id,
        status: status,
        source_section: sourceSectionParams(),
        redigest: allowRedigest
      },
      type: 'POST',
      url: '/client_admin/tiles/' + id + '/sort',
      success: function() {
        updateTileVisibility();
        Airbo.TileThumbnail.initTile(id);
      }
    });
  }

  function sourceSectionParams() {
    var section;
    if (sourceSectionName) {
      section = $("#" + sourceSectionName);
      sourceSectionName = null;
      return sectionParams(section);
    } else {
      return null;
    }
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
    return parseInt((ref = tile.find(".completions").text().match(/\d+/)) != null ? ref[0] : void 0);
  }

  function turnOnDraftBlocking(tile, section) {
    var completions, status;
    status = getTilesSection(tile);
    completions = tileCompletionsNum(tile);
    if (status !== "draft" && completions > 0) {
      showDraftBlockedOverlay(true);
      $("#draft").sortable("disable");
      return section.sortable("refresh");
    }
  }

  function turnOffDraftBlocking(tile, section) {
    $("#draft").sortable("enable");
    section.sortable("refresh");
  }

  function updateTileVisibility() {
    var i, len, ref, results, section;
    ref = sectionNames;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      section = ref[i];
      results.push(updateTileVisibilityIn(section));
    }
    return results;
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

  function updateTileVisibilityIn(section) {
    var i, index, len, results, tile, tiles, visibleTilesNumber;
    tiles = $("#" + section).find("> " + notDraggedTileSelector);
    visibleTilesNumber = visibleTilesNumberIn(section);
    results = [];
    for (index = i = 0, len = tiles.length; i < len; index = ++i) {
      tile = tiles[index];
      if (index < visibleTilesNumber) {
        results.push($(tile).css("display", "block"));
      } else {
        results.push($(tile).css("display", "none"));
      }
    }
    return results;
  }

  function showDraftBlockedOverlay(isOn) {
    if (isOn) {
      $(".draft_overlay").show();
    } else {
       $(".draft_overlay").hide();
    }
  }

  function isDraftBlockedOverlayShowed() {
     return $(".draft_overlay").css("display") === "block";
  }


  function showDraftBlockedMess(isOn, section) {
    var mess_div;
    if (isOn) {
      mess_div = section.closest(".manage_tiles").find(".draft_blocked_message");
      mess_div.show();
      if (!iOSdevice()) {
         $('html, body').scrollTo(mess_div, {
          duration: 500
        });
      }
    } else {
      $(".draft_blocked_message").hide();
    }
  }

  function iOSdevice() {
    return navigator.userAgent.match(/(iPad|iPhone|iPod)/g);
  }

  function isTileInSection(tile, section) {
    return getTilesSection(tile) === section.attr("id");
  }

  function cancelTileMoving() {
    if (sourceSectionName) {
      return $("#" + sourceSectionName).sortable("cancel").sortable("refresh");
    }
  }

  function moveComfirmationModal(tile) {
    window.moveConfirmationDeferred = $.Deferred();
    window.moveConfirmation = window.moveConfirmationDeferred.promise();

    confirmReposting(tile);

  };


  function confirmReposting(tile){
    var checkConfirm = function (isConfirm){
      if (isConfirm) {
        allowRedigest = $(".sweet-alert input#digestable").is(':checked');
        window.moveConfirmationDeferred.resolve();
      }else{
        tileInfo(tile,"show");
        window.moveConfirmationDeferred.reject();
      }

      resetGloballVariables();
    }
    Airbo.TileAction.confirmUnarchive(checkConfirm);
  }


  function resetGloballVariables() {
    sourceSectionName = null;
    moveConfirmationDeferred = null;
    moveConfirmation = null;
  }



  function isTileMoved(tile, fromSectionName, toSectionName) {
    return getTilesSection(tile) === toSectionName && sourceSectionName === fromSectionName;
  }


  function init(){
    //initDraftDroppable();
    initTileSorting();
  }


  return {
    init: init,
    updateTileVisibilityIn: updateTileVisibilityIn,
  }


})();

$(function(){
if(Airbo.Utils.supportsFeatureByPresenceOfSelector(".client_admin-tiles-index"))
  Airbo.TileDragDropSort.init();
 window.expandDraftSectionOrSuggestionBox();
})

//window.updateTileVisibilityIn = updateTileVisibilityIn;
//window.updateTilesAndPlaceholdersAppearance = updateTilesAndPlaceholdersAppearance;
