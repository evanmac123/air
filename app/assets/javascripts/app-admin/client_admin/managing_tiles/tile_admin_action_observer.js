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
    var currTile = payload.currTile;
    var updatedTile = payload.updatedTile;

    moveTile(currTile, updatedTile);
    $(tileModalSelector).foundation("reveal", "close");
  }

  function moveTile(currTile, updatedTile) {
    var sections = {
      active: "active",
      draft: "draft",
      archive: "archive",
      user_submitted: "suggested",
      ignored: "suggested"
    };

    var status = updatedTile.data("status");
    var newSection = "#" + sections[status];

    currTile.fadeOut();
    $(newSection).prepend(updatedTile);

    Airbo.TilePlaceHolderManager.perform();
    Airbo.TileThumbnailMenu.initMoreBtn(updatedTile.find(".pill.more"));
  }

  function replaceTileContent(tile, id) {
    selector = ".tile_container[data-tile-container-id=" + id + "]";
    $(selector).replaceWith(tile);
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
