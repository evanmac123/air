var Airbo = window.Airbo || {};

Airbo.ClientAdminTileManager = (function(){

  function initVars() {
    tileThumbnail = Airbo.ClientAdminTileThumbnail.init(this);
  }

  function init() {
    initVars();
    Airbo.TileStatsModal.init();
  }

  return {
    init: init,
  };
}());
