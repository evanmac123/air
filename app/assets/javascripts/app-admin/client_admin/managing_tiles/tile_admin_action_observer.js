var Airbo = window.Airbo || {};

Airbo.TileAdminActionObserver = (function() {
  var tileModalSelector = "#tile_preview_modal";
  var sections = {
    archive: "archive",
    active: "active",
    draft: "draft",
    plan: "plan",
    user_submitted: "suggested",
    ignored: "suggested"
  };

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
    var status = payload.updatedTile.data("status");
    var $tilesContainer = $("#" + sections[status]);

    if (status === "ignored" || status === "user_submitted") {
      moveSameSectionTile(payload.updatedTile, $tilesContainer);
    } else {
      Airbo.TilesIndexLoader.resetTiles($tilesContainer);
    }

    payload.currTile.remove();
    $(tileModalSelector).foundation("reveal", "close");
  }

  function moveSameSectionTile(updatedTile, $tilesContainer) {
    $tilesContainer.prepend(updatedTile);

    Airbo.TilePlaceHolderManager.perform();
    Airbo.TileThumbnailMenu.initMoreBtn(updatedTile.find(".pill.more"));
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
