var Airbo = window.Airbo || {};

$(function() {
  if (Airbo.Utils.nodePresent(".js-ca-tiles-index-module")) {
    Airbo.TilesIndexTabManager.init();
    Airbo.TilesIndexFilterManager.init();
    Airbo.TileCountsManager.init();
    Airbo.CampaignManager.init();
    Airbo.SuggestionBox.init();
  }
});
