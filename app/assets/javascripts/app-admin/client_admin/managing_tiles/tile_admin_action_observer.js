var Airbo = window.Airbo || {};

Airbo.TileAdminActionObserver = (function() {
  var tileModalSelector = "#tile_preview_modal";

  function init() {
    Airbo.PubSub.subscribe("/tile-admin/tile-status-updated", function(
      event,
      payload
    ) {
      tileUpdateStatusSuccess(payload);
    });

    Airbo.PubSub.subscribe("/tile-admin/tile-copied", function(event, payload) {
      Airbo.TileManager.refreshOrAddTileThumb(payload.data);
    });

    Airbo.PubSub.subscribe("/tile-admin/tile-deleted", function(
      event,
      payload
    ) {
      payload.tile.remove();
      Airbo.TilePlaceHolderManager.perform();
    });
  }

  function tileUpdateStatusSuccess(payload) {
    var $tilesContainer = $("#" + payload.updatedTile.data("status"));
    Airbo.TilesIndexLoader.resetTiles($tilesContainer);
    payload.currTile.remove();

    $(tileModalSelector).foundation("reveal", "close");
  }

  return {
    init: init
  };
})();

$(function() {
  if ($(".client_admin-tiles-index").length > 0) {
    Airbo.TileAdminActionObserver.init();
  }
});
