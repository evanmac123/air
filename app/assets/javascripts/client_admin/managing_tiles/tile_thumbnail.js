var Airbo = window.Airbo || {};

Airbo.TileThumbnail = (function() {
  var tileManager
  ;
  function initTile(tileId) {
    tileContainer = $(".tile_container[data-tile-id='" + tileId + "']");

    tileContainer.find(".update_status").click(function(e){
      e.preventDefault();
      e.stopPropagation();
      target = $(this);
      Airbo.TileAction.updateStatus(target);
    });
  }
  function initEvents(){
    tileIds = $(".tile_container:not(.placeholder_container)").map(function(){
      return $(this).data("tile-id");
    });
    uniqueTileIds = jQuery.unique(tileIds);

    uniqueTileIds.each(function(){
      initTile( this );
    });
  }
  function init(AirboTileManager) {
    tileManager = AirboTileManager;
    initEvents();
  }
  return {
    init: init,
    initTile: initTile
  }
}());
