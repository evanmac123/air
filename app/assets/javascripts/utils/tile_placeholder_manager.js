var Airbo = window.Airbo || {};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.TilePlaceHolderManager = (function(){

  var placeholderSelector =".tile_container.placeholder_container:not(.hidden_tile)"
    , notDraggedTileSelector = ".tile_container:not(.ui-sortable-helper):not(.hidden_tile)"
    , sectionNames = ["draft", "active", "archive", "suggestion_box"]
    , placeholderHTML = '<div class="tile_container placeholder_container">' +
  '<div class="tile_thumbnail placeholder_tile"></div></div>'
;


  function updateNoTilesSection(section) {
    var no_tiles_section;
    no_tiles_section = $("#" + section).find(".no_tiles_section");
    if ($("#" + section).children(notDraggedTileSelector).length === 0) {
      return no_tiles_section.show();
    } else {
      return no_tiles_section.hide();
    }
  };

  function numberInRow(section) {
    if (section === "draft" || section === "suggestion_box") {
      return 6;
    } else {
      return 4;
    }
  };

  /*TODO refactor and combine these three functions
   * updateAllNoTilesSections
   * updateTileVisibility
   * updateAllPlaceholders
  */

  function updateAllNoTilesSections() {
    var i, len, section, results=[];

    for (i = 0, len = sectionNames.length; i < len; i++) {
      section = sectionNames[i];
      results.push(updateNoTilesSection(section));
    }
    return results;
  };

  function updateTileVisibility() {
    var i, len, section, results=[];

    for (i = 0, len = sectionNames.length; i < len; i++) {
      section = sectionNames[i];
      results.push(updateTileVisibilityIn(section));
    }
    return results;
  };

  function updateAllPlaceholders() {
    var i, len, section, results=[];

    for (i = 0, len = sectionNames.length; i < len; i++) {
      section = sectionNames[i];
      results.push(updatePlaceholders(section));
    }

    return results;
  }

  function visibleTilesNumberIn(section) {
    if (section === "draft" || section === "suggestion_box") {
      if (draftSectionIsCompressed()) {
        return numberInRow(section);
      } else {
        return 9999;
      }
    } else if (section === "archive") {
      if( Airbo.TileManager.getManagerType() == "main" ){
        return numberInRow(section);
      } else {
        return 9999;
      }
    } else {
      return 9999;
    }
  };

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
  };


  function draftSectionIsCompressed() {
    return $("#draft_tiles").hasClass("compressed_section");
  };

  function updatePlaceholders(section) {
    var allTilesNumber, expectedPlaceholdersNumber, placeholdersNumber, tilesNumber;

    allTilesNumber = $("#" + section).find(notDraggedTileSelector).length;
    placeholdersNumber = $("#" + section).find(placeholderSelector).length;
    tilesNumber = allTilesNumber - placeholdersNumber;

    expectedPlaceholdersNumber = (numberInRow(section) - (tilesNumber % numberInRow(section))) % numberInRow(section);

    removePlaceholders(section);
    addPlaceholders(section, expectedPlaceholdersNumber);

  };


  function removePlaceholders(section) {
    $("#" + section).children(placeholderSelector).remove();
  }

  function addPlaceholders(section, number) {
    $("#" + section).append(placeholderHTML.times(number));
  }


  function updateTilesAndPlaceholdersAppearance() {
    updateAllPlaceholders();
    updateAllNoTilesSections();
    updateTileVisibility();
  }

  function init(){
   //noop
  }
  return {
    init: init,
    updateTilesAndPlaceholdersAppearance: updateTilesAndPlaceholdersAppearance
  };

}());
