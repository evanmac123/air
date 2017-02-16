var Airbo = window.Airbo || {};

Airbo.UserTileSearch = (function(){
  function init() {
    $(".tile_thumb_link").on("click", function(e) {
      e.preventDefault();
      var tileIds = getNeighboringTileIds($(this));
      debugger
      window.location = $(this).attr('href') + "?from_search=true&tile_ids=" + tileIds;
    });
  }

  function getNeighboringTileIds(self) {
    return Airbo.TileThumbnailManagerBase.getNeighboringTileIdsInContainer(self);
  }

  return {
    init: init
  };
}());
