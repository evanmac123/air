$(function(){
  if( $('.client_admin_tiles.tile-grid.endless_scroll_content_container').length > 0 ) {
    $('.client_admin_tiles.tile-grid.endless_scroll_content_container').each(function(index, container) {
      Airbo.Utils.EndlessScroll.init($(container), Airbo.SearchTileThumbnail.initTiles);
    });
  }
});

$(function(){
  if( $(".search.tile-grid.explore_tiles").length > 0 ) {
    $(".search.tile-grid.explore_tiles").each(function(index, container) {
      Airbo.Utils.EndlessScroll.init($(container), Airbo.CopyTileToBoard.bindThumbnailCopyButton);
    });
  }
});

$(function(){
  if( $(".search.tile-grid.user_tiles").length > 0 ) {
    $(".search.tile-grid.user_tiles").each(function(index, container) {
      Airbo.Utils.EndlessScroll.init($(container), Airbo.UserTileSearch.init);
    });
  }
});
