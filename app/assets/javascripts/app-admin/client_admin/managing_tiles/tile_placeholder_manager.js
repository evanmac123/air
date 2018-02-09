var Airbo = window.Airbo || {};

Airbo.TilePlaceHolderManager = (function() {
  var placeholderSel = ".tile_container.placeholder_container";
  var tileSel = ".tile_container:not(.placeholder_container)";
  var tileWithPlaceholderSel = tileSel + ", " + placeholderSel;
  var sectionNames = ["draft", "active", "archive", "suggested"];
  var numInRow = 4;
  var tilesPerPage = 16;

  function updateTileVisibility() {
    $(sectionNames).each(function(index, section) {
      updateTileVisibilityIn($("#" + section));
    });
  }

  function updateAllPlaceholders() {
    $(sectionNames).each(function(index, section) {
      updatePlaceholders($("#" + section));
    });
  }

  function updateTileVisibilityIn($section) {
    var tiles = $section.find("> " + tileWithPlaceholderSel);
    $(tiles).each(function(index, tile) {
      $(tile).css("display", "block");
    });
  }

  function updatePlaceholders($section) {
    var allTilesNum = $section.find(tileWithPlaceholderSel).length;
    if (allTilesNum < tilesPerPage) {
      var tilesNum = $section.find(tileSel).length;
      var expectedPlaceholdersNum = numInRow - tilesNum % numInRow;

      removePlaceholders($section);
      addPlaceholders($section, expectedPlaceholdersNum);
    }
  }

  function removePlaceholders($section) {
    $section.children(placeholderSel).remove();
  }

  function addPlaceholders($section, number) {
    var placeholderHTML =
      '<div class="tile_container placeholder_container"><div class="tile_thumbnail placeholder_tile"></div></div>';

    $section.append(placeholderHTML.repeat(number));
  }

  function updateTilesAndPlaceholdersAppearance() {
    updateAllPlaceholders();
    // updateTileVisibility();
  }

  function init() {
    updateAllPlaceholders();
  }

  return {
    init: init,
    updateTilesAndPlaceholdersAppearance: updateTilesAndPlaceholdersAppearance
  };
})();

$(function() {
  if ($(".js-tiles-index-section").length > 0) {
    Airbo.TilePlaceHolderManager.init();
  }
});
