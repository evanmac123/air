$(function() {
  if ($(".tile_wall_explore.endless_scroll_content_container").length > 0) {
    $(".tile_wall_explore.endless_scroll_content_container").each(function(
      index,
      container
    ) {
      Airbo.Utils.EndlessScroll.init(
        $(container),
        Airbo.CopyTileToBoard.bindThumbnailCopyButton
      );
    });
  }
});
