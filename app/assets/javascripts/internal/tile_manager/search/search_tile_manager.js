var Airbo = window.Airbo || {};

Airbo.SearchTileManager = (function(){

  function init() {
    var userType = $(".explore-search-results").data().userType;

    if (userType == "user") {
      Airbo.UserTileSearch.init();
    } else {
      Airbo.TileManager.init("search", Airbo.SearchTileThumbnail);
      Airbo.TileStatsModal.init();
    }
  }

  function updateSections() {
    
  }

  return {
    init: init,
  };
}());
