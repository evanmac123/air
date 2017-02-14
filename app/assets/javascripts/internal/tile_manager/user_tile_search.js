var Airbo = window.Airbo || {};

Airbo.UserTileSearch = (function(){
  function init() {
    $(".tile_thumb_link").on("click", function(e) {
      e.preventDefault();
      var tileIds = Airbo.TileThumbnailManagerBase.getTileIdsInContainer($(this));

      window.location = $(this).attr('href') + "?from_search=true&tile_ids=" + tileIds;
    });
  }

  return {
    init: init
  };
}());
