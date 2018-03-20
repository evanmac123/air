$(function() {
  if ($(".client_admin_tiles.endless_scroll_content_container").length > 0) {
    $(".client_admin_tiles.endless_scroll_content_container").each(function(
      index,
      container
    ) {
      Airbo.Utils.EndlessScroll.init($(container), Airbo.TileThumbnail.init);
    });
  }

  if ($(".org_tiles.endless_scroll_content_container").length > 0) {
    $(".org_tiles.endless_scroll_content_container").each(function(
      index,
      container
    ) {
      Airbo.Utils.EndlessScroll.init(
        $(container),
        Airbo.CopyTileToBoard.bindThumbnailCopyButton
      );
    });
  }

  if ($(".search.explore_tiles").length > 0) {
    $(".search.explore_tiles").each(function(index, container) {
      Airbo.Utils.EndlessScroll.init(
        $(container),
        Airbo.CopyTileToBoard.bindThumbnailCopyButton
      );
    });
  }

  if ($(".search.user_tiles").length > 0) {
    $(".search.user_tiles").each(function(index, container) {
      Airbo.Utils.EndlessScroll.init($(container), Airbo.UserTileSearch.init);
    });
  }
});
