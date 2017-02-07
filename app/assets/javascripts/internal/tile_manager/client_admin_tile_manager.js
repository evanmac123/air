var Airbo = window.Airbo || {};

Airbo.ClientAdminTileManager = (function(){

  function init() {
    Airbo.TileManager.init("search", Airbo.ClientAdminTileThumbnail);
    Airbo.TileStatsModal.init();
  }

  return {
    init: init,
  };
}());
