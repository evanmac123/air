var Airbo = window.Airbo || {};

Airbo.SearchTileManager = (function(){


  var tileWrapperSelector =".tile_container";

  function updateTileSection(data){

    var selector,
    section = pageSectionByStatus(data.tileStatus),
      tile = $(data.tile),
      img = tile.find(".tile_thumbnail_image>img")[0];

    $(img).css({height:"100%",width:"100%"});
  }

  function init() {
    var userType = $(".explore-search-results").data().userType;

    if (userType == "user") {
      Airbo.UserTileSearch.init();
    } else {
      Airbo.TileStatsModal.init();
    }

    Airbo.SearchTileThumbnail.init();
  }

  function replaceTileContent(tile, id){
    selector = tileContainerByDataTileId(id);
    $(selector).each(function(idx, oldTile){
      $(oldTile).replaceWith(tile);
    });
  }

  function tileContainerByDataTileId(id){
    return  $(tileWrapperSelector + "[data-tile-container-id=" + id + "]");
  }

  function updateSections(data) {
    var tile = data.tile
    replaceTileContent(tile, data.tileId)
  }

  return {
    init: init,
    updateSections: updateSections
  };
}());
