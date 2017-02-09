$(function(){
  if( $('.client_admin_tiles.tile-grid.endless_scroll_content_container').length > 0 ) {
    $('.client_admin_tiles.tile-grid.endless_scroll_content_container').each(function(index, container) {
      Airbo.Utils.EndlessScroll.init($(container), Airbo.SearchTileThumbnail.initTiles());
    });
  }
});
