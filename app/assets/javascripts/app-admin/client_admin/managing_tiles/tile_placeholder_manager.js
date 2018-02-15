var Airbo = window.Airbo || {};

Airbo.TilePlaceHolderManager = (function() {
  var placeholderSel = ".tile_container.placeholder_container";
  var tileSel = ".tile_container:not(.placeholder_container)";
  var tileWithPlaceholderSel = tileSel + ", " + placeholderSel;
  var sectionNames = ["plan", "draft", "active", "archive", "suggested"];
  var numInRow = 4;

  function updateAllPlaceholders() {
    $(sectionNames).each(function(index, section) {
      updatePlaceholders($("#" + section));
    });
  }

  function updatePlaceholders($section) {
    var allTilesNum = $section.find(tileWithPlaceholderSel).length;
    if ($section.data("lastPage") === true) {
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

  function perform() {
    updateAllPlaceholders();
  }

  return {
    perform: perform
  };
})();

$(function() {
  if ($(".js-tiles-index-section").length > 0) {
    Airbo.TilePlaceHolderManager.perform();
  }
});
