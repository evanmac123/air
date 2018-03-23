var Airbo = window.Airbo || {};

Airbo.TilesIndexLoader = (function() {
  function loadMore($contentContainer) {
    $contentContainer.siblings($(".js-endless-scroll-loading")).show();

    $.ajax({
      url: "/api/client_admin/tile_thumbnails",
      data: {
        page: $contentContainer.data("nextPage"),
        status: $contentContainer.data("status")
      },
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

  return {
    loadMore: loadMore
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
