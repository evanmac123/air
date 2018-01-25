var Airbo = window.Airbo || {};

Airbo.TileAdminActionObserver = (function() {
  var tileModalSelector = "#tile_preview_modal";

  function init() {
    Airbo.PubSub.subscribe("/tile-admin/tile-status-updated", function(
      event,
      payload
    ) {
      tileUpdateStatusSucces(payload);
    });

    Airbo.PubSub.subscribe("/tile-admin/tile-copied", function(event, payload) {
      Airbo.TileManager.updateTileSection(payload.data);
      updateShowMoreDraftTilesButton();
    });

    Airbo.PubSub.subscribe("/tile-admin/tile-deleted", function(
      event,
      payload
    ) {
      var isArchiveSection = payload.tile.data("status") == "archive";
      payload.tile.remove();
      Airbo.Utils.TilePlaceHolderManager.updateTilesAndPlaceholdersAppearance();
      updateShowMoreDraftTilesButton();
    });
  }

  function updateUserSubmittedTilesCounter() {
    submittedTile = $(".tile_thumbnail.user_submitted");
    $("#suggestion_box_title")
      .find(".num-items")
      .html("(" + submittedTile.length + ")");
  }

  function tileUpdateStatusSucces(payload) {
    var currTile = payload.currTile;
    var updatedTile = payload.updatedTile;

    Airbo.Utils.TilePlaceHolderManager.updateTilesAndPlaceholdersAppearance();
    swal.close();
    if (window.location.pathname.indexOf("inactive_tiles") > 0) {
      currTile.hide();
    } else {
      $(tileModalSelector).foundation("reveal", "close");
      moveTile(currTile, updatedTile);
    }
  }

  function moveTile(currTile, updatedTile) {
    function fromSuggestionBox() {
      return currTile.data("status") == "user_submitted" || status == "ignored";
    }

    sections = {
      active: "active",
      draft: "draft",
      archive: "archive",
      user_submitted: "suggestion_box",
      ignored: "suggestion_box"
    };

    var status = updatedTile.data("status");
    var newSection = "#" + sections[status];

    currTile.remove();
    $(newSection).prepend(updatedTile);
    Airbo.TileDragDropSort.updateTilesAndPlaceholdersAppearance();

    if (fromSuggestionBox(currTile)) {
      updateUserSubmittedTilesCounter();
    }

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
