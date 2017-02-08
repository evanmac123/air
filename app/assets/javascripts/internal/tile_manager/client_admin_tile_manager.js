var Airbo = window.Airbo || {};

Airbo.ClientAdminTileManager = (function(){

  function init() {
    var userType = $(".explore-search-results").data().userType;

    if (userType == "user") {
      Airbo.UserTileSearch.init();
    } else {
      Airbo.TileManager.init("search", Airbo.ClientAdminTileThumbnail);
      Airbo.TileStatsModal.init();
    }
  }

  return {
    init: init,
  };
}());
