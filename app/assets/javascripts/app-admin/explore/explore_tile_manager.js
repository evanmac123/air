var Airbo = window.Airbo || {};

Airbo.ExploreTileManager = (function() {
  function initEvents() {
    $("body").on("click", ".tile_thumb_link_explore", function(e) {
      e.preventDefault();
      getExploreTile($(this).attr("href"), $(this).data("tileId"));
    });
  }

  function getExploreTile(link, id, tilePreview) {
    var tile = Airbo.TileManager.tileContainerByDataTileId(id);
    var next = nextTile(tile).data("tileContainerId");
    var prev = prevTile(tile).data("tileContainerId");

    if (!tilePreview) {
      tilePreview = Airbo.ExploreTilePreview;
    }

    $.ajax({
      type: "GET",
      dataType: "html",
      url: link,
      data: { partial_only: true, next_tile: next, prev_tile: prev },
      success: function(data, status, xhr) {
        tilePreview.init();
        tilePreview.open(data);
      },

      error: function(jqXHR, textStatus, error) {
        console.log(error);
      }
    });
  }

  function nextTile(tile) {
    return Airbo.TileThumbnailManagerBase.nextTile(tile);
  }

  function prevTile(tile) {
    return Airbo.TileThumbnailManagerBase.prevTile(tile);
  }

  function launchTileIfRequested() {
    var requestedTile = $("body.explore").data("requestedTile");

    if (requestedTile) {
      getExploreTile("/explore/tile/" + requestedTile, requestedTile);
    }
  }

  function init() {
    initEvents();
    launchTileIfRequested();
  }

  return {
    init: init,
    getExploreTile: getExploreTile
  };
})();

$(function() {
  if ($(".explore").length && !$("#root").length) {
    Airbo.ExploreTileManager.init();
  }
});
