var Airbo = window.Airbo || {};

Airbo.TilesIndexLoader = (function() {
  function loadMore($contentContainer) {
    if ($contentContainer.data("lastPage") !== true) {
      $contentContainer.siblings($(".js-endless-scroll-loading")).show();

      $.ajax({
        url: "/api/client_admin/tile_thumbnails",
        data: queryData($contentContainer),
        method: "GET",
        dataType: "json",
        success: function(data) {
          $contentContainer.siblings($(".js-endless-scroll-loading")).hide();

          $contentContainer.data("page", data.page);
          $contentContainer.data("nextPage", data.nextPage);
          $contentContainer.data("lastPage", data.lastPage);
          $contentContainer.append(data.content);
          Airbo.TilePlaceHolderManager.perform();
          Airbo.TileThumbnailMenu.initMoreBtn();
        }
      });
    }
  }

  function queryData($contentContainer) {
    return {
      page: $contentContainer.data("nextPage"),
      status: $contentContainer.data("status"),
      month: $contentContainer.data("month"),
      year: $contentContainer.data("year"),
      campaign: $contentContainer.data("campaign"),
      sort: $contentContainer.data("sort")
    };
  }

  function clearTiles($contentContainer) {
    $contentContainer.children().remove();
    $contentContainer.data("page", "");
    $contentContainer.data("nextPage", 1);
    $contentContainer.data("lastPage", false);
  }

  function resetTiles($contentContainer) {
    clearTiles($contentContainer);
    loadMore($contentContainer);
  }

  return {
    loadMore: loadMore,
    resetTiles: resetTiles
  };
})();

$(function() {
  if ($(".js-tiles-index-section.js-endless-scroll").length > 0) {
    $(".js-tiles-index-section.js-endless-scroll").each(function(
      index,
      container
    ) {
      Airbo.Utils.EndlessScrollUtil.init(
        $(container),
        Airbo.TilesIndexLoader.loadMore
      );
    });
  }
});
