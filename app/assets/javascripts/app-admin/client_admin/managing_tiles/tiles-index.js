var Airbo = window.Airbo || {};

$(function() {
  if (Airbo.Utils.nodePresent(".js-ca-tiles-index-module")) {
    Airbo.TilesIndexTabManager.init();
    Airbo.TileCountsManager.init();
    Airbo.SuggestionBox.init();
  }
});
