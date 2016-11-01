String.prototype.times = function(n) {
  return Array.prototype.join.call({
    length: n + 1
  }, this);
};

var suppressDigestOnUnarchiveTile = true;

window.dragAndDropProperties = {
  items: ".tile_container:not(.placeholder_container)",
  connectWith: ".manage_section",
  cancel: ".placeholder_container, .no_tiles_section",
  revert: true,
  tolerance: "pointer",
  placeholder: "tile_container",
  handle: ".tile-wrapper"
};

window.dragAndDropTiles = function() {
  var addPlaceholders, cancelTileMoving, completedTileWasAttemptedToBeMovedInBlockedDraft, draftSectionIsCompressed, dragAndDropTilesEvents, findTileId, getTilesSection, iOSdevice, isDraftBlockedOverlayShowed, isTileInSection, isTileMoved, moveComfirmationModal, notDraggedTileSelector, numberInRow, overEvent, placeholderHTML, placeholderSelector, receiveEvent, removePlaceholders, resetGloballVariables, saveTilePosition, sectionNames, sectionParams, showDraftBlockedMess, showDraftBlockedOverlay, sourceSectionParams, startEvent, stopEvent, tileCompletionsNum, tileInfo, turnOffDraftBlocking, turnOnDraftBlocking, updateAllNoTilesSections, updateAllPlaceholders, updateEvent, updateNoTilesSection, updatePlaceholders, updateTileInSectionClass, updateTileVisibility, updateTileVisibilityIn, updateTilesAndPlaceholdersAppearance, visibleTilesNumberIn;

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

  dragAndDropTilesEvents = {
    update: function(event, ui) {
      var section, tile;
      section = $(this);
      tile = ui.item;
      debugger
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

  window.tileSortable = $("#draft, #active, #archive").sortable($.extend(window.dragAndDropProperties, dragAndDropTilesEvents)).disableSelection();

  updateEvent = function(event, tile, section) {
    if (isTileInSection(tile, section)) {
      tileInfo(tile, "remove");
      return saveTilePosition(tile);
    } else {
      return window.sourceSectionName = section.attr("id");
    }
  };

  overEvent = function(event, tile, section) {
    updateTilesAndPlaceholdersAppearance();
    return updateTileInSectionClass(tile, section);
  };

  startEvent = function(event, tile, section) {
    resetGloballVariables();
    turnOnDraftBlocking(tile, section);
    showDraftBlockedMess(false);
    return tileInfo(tile, "hide");
  };

  receiveEvent = function(event, tile, section) {
    var id;
    if (completedTileWasAttemptedToBeMovedInBlockedDraft()) {
      return cancelTileMoving();
    } else if (isTileMoved(tile, "archive", "active") && tileCompletionsNum(tile) > 0) {
      return moveComfirmationModal(tile);
    } else if (isTileMoved(tile, "draft", "active")) {
      id = findTileId(tile);
      return Airbo.TileAction.movePing(id, "active", "Dragged tile to move");
    }
  };

  stopEvent = function(event, tile, section) {
    turnOffDraftBlocking(tile, section);
    if (completedTileWasAttemptedToBeMovedInBlockedDraft()) {
      showDraftBlockedMess(true, section);
      showDraftBlockedOverlay(false);
    }
    updateTilesAndPlaceholdersAppearance();
    return tileInfo(tile, "show");
  };

  numberInRow = function(section) {
    if (section === "draft" || section === "suggestion_box") {
      return 6;
    } else {
      return 4;
    }
  };

  placeholderSelector = function() {
    return ".tile_container.placeholder_container:not(.hidden_tile)";
  };

  notDraggedTileSelector = function() {
    return ".tile_container:not(.ui-sortable-helper):not(.hidden_tile)";
  };

  placeholderHTML = function() {
    return '<div class="tile_container placeholder_container">' + '<div class="tile_thumbnail placeholder_tile"></div>' + '</div>';
  };

  sectionNames = function() {
    return ["draft", "active", "archive", "suggestion_box"];
  };

  findTileId = function(tile) {
    return tile.find(".tile_thumbnail").data("tile-id");
  };

  getTilesSection = function(tile) {
    return tile.closest(".manage_section").attr("id");
  };

  updateTileInSectionClass = function(tile, section) {
    return tile.removeClass("tile_in_draft").removeClass("tile_in_active").removeClass("tile_in_archive").addClass("tile_in_" + section.attr("id"));
  };
  updateTilesAndPlaceholdersAppearance = function() {
    updateAllPlaceholders();
    updateAllNoTilesSections();
    return updateTileVisibility();
  };

  window.updateTilesAndPlaceholdersAppearance = updateTilesAndPlaceholdersAppearance;
  updateAllPlaceholders = function() {
    var i, len, ref, results, section;
    ref = sectionNames();
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      section = ref[i];
      results.push(updatePlaceholders(section));
    }
    return results;
  };

  updatePlaceholders = function(section) {
    var allTilesNumber, expectedPlaceholdersNumber, placeholdersNumber, tilesNumber;
    allTilesNumber = $("#" + section).find(notDraggedTileSelector()).length;
    placeholdersNumber = $("#" + section).find(placeholderSelector()).length;
    tilesNumber = allTilesNumber - placeholdersNumber;
    expectedPlaceholdersNumber = (numberInRow(section) - (tilesNumber % numberInRow(section))) % numberInRow(section);
    removePlaceholders(section);
    return addPlaceholders(section, expectedPlaceholdersNumber);
  };

  removePlaceholders = function(section) {
    return $("#" + section).children(placeholderSelector()).remove();
  };

  addPlaceholders = function(section, number) {
    return $("#" + section).append(placeholderHTML().times(number));
  };

  updateAllNoTilesSections = function() {
    var i, len, ref, results, section;
    ref = sectionNames();
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      section = ref[i];
      results.push(updateNoTilesSection(section));
    }
    return results;
  };

  updateNoTilesSection = function(section) {
    var no_tiles_section;
    no_tiles_section = $("#" + section).find(".no_tiles_section");
    if ($("#" + section).children(notDraggedTileSelector()).length === 0) {
      return no_tiles_section.show();
    } else {
      return no_tiles_section.hide();
    }
  };

  tileInfo = function(tile, action) {
    var controlElements, shadowOverlay;
    controlElements = tile.find(".tile_buttons, .tile_stats");
    shadowOverlay = tile.find(".shadow_overlay");
    if (action === "show") {
      controlElements.css("display", "");
      return shadowOverlay.css("opacity", "");
    } else if (action === "hide") {
      //controlElements.hide();
      return shadowOverlay.css("opacity", "0");
    } else if (action === "remove") {
      return controlElements.remove();
    }
  };

  saveTilePosition = function(tile) {
    var id, left_tile_id, right_tile_id, status;
    id = findTileId(tile);
    left_tile_id = findTileId(tile.prev());
    right_tile_id = findTileId(tile.next());
    status = getTilesSection(tile);
    return $.ajax({
      data: {
        left_tile_id: left_tile_id,
        right_tile_id: right_tile_id,
        status: status,
        source_section: sourceSectionParams(),
        suppress: suppressDigestOnUnarchiveTile
      },
      type: 'POST',
      url: '/client_admin/tiles/' + id + '/sort',
      success: function() {
        updateTileVisibility();
        return Airbo.TileThumbnail.initTile(id);
      }
    });
  };

  sourceSectionParams = function() {
    var section;
    if (window.sourceSectionName) {
      section = $("#" + window.sourceSectionName);
      window.sourceSectionName = null;
      return sectionParams(section);
    } else {
      return null;
    }
  };


  sectionParams = function(section) {
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
  };
  tileCompletionsNum = function(tile) {
    var ref;
    return parseInt((ref = tile.find(".completions").text().match(/\d+/)) != null ? ref[0] : void 0);
  };
  turnOnDraftBlocking = function(tile, section) {
    var completions, status;
    status = getTilesSection(tile);
    completions = tileCompletionsNum(tile);
    if (status !== "draft" && completions > 0) {
      $("#draft").sortable("disable");
      return section.sortable("refresh");
    }
  };
  turnOffDraftBlocking = function(tile, section) {
    $("#draft").sortable("enable");
    return section.sortable("refresh");
  };
  updateTileVisibility = function() {
    var i, len, ref, results, section;
    ref = sectionNames();
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      section = ref[i];
      results.push(updateTileVisibilityIn(section));
    }
    return results;
  };
  draftSectionIsCompressed = function() {
    return $("#draft_tiles").hasClass("compressed_section");
  };
  visibleTilesNumberIn = function(section) {
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
  };
  updateTileVisibilityIn = function(section) {
    var i, index, len, results, tile, tiles, visibleTilesNumber;
    tiles = $("#" + section).find("> " + notDraggedTileSelector());
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
  };
  window.updateTileVisibilityIn = updateTileVisibilityIn;
  showDraftBlockedOverlay = function(isOn) {
    if (isOn) {
      return $(".draft_overlay").show();
    } else {
      return $(".draft_overlay").hide();
    }
  };

  isDraftBlockedOverlayShowed = function() {
    return $(".draft_overlay").css("display") === "block";
  };

  completedTileWasAttemptedToBeMovedInBlockedDraft = function() {
    return isDraftBlockedOverlayShowed();
  };

  showDraftBlockedMess = function(isOn, section) {
    var mess_div;
    if (isOn) {
      mess_div = section.closest(".manage_tiles").find(".draft_blocked_message");
      mess_div.show();
      if (!iOSdevice()) {
        return $('html, body').scrollTo(mess_div, {
          duration: 500
        });
      }
    } else {
      return $(".draft_blocked_message").hide();
    }
  };

  iOSdevice = function() {
    return navigator.userAgent.match(/(iPad|iPhone|iPod)/g);
  };

  isTileInSection = function(tile, section) {
    return getTilesSection(tile) === section.attr("id");
  };

  cancelTileMoving = function() {
    if (window.sourceSectionName) {
      return $("#" + window.sourceSectionName).sortable("cancel").sortable("refresh");
    }
  };

  moveComfirmationModal = function(tile) {
    window.moveConfirmationDeferred = $.Deferred();
    window.moveConfirmation = window.moveConfirmationDeferred.promise();

    confirmReposting(tile);

  };



  function confirmReposting(tile){
    Airbo.TileAction.confirmUnarchive(
      function(isConfirm){
        if (isConfirm) {
          suppressDigestOnUnarchiveTile= !$(".sweet-alert input#digestable").is(':checked');
          window.moveConfirmationDeferred.resolve();
        }else{
          tile.find(".tile_buttons, .tile_stats").show();
          window.moveConfirmationDeferred.reject();
        }

        resetGloballVariables();
      });
  }


  isTileMoved = function(tile, fromSectionName, toSectionName) {
    return getTilesSection(tile) === toSectionName && window.sourceSectionName === fromSectionName;
  };

  return resetGloballVariables = function() {
    window.sourceSectionName = null;
    window.moveConfirmationDeferred = null;
    return window.moveConfirmation = null;
  };
};
