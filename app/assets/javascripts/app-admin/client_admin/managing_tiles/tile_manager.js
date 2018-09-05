var Airbo = window.Airbo || {};

Airbo.TileManager = (function() {
  var newTileBtnSel = ".js-new-tile-button";

  function tileContainerByDataTileId(id) {
    return $(".tile_container[data-tile-container-id=" + id + "]");
  }

  function refreshOrAddTileThumb(data) {
    var $tile = $(data.tile);
    var $tilesForRefresh = tileContainerByDataTileId(data.tileId);

    if ($tilesForRefresh.length > 0) {
      replaceTileContent($tile, $tilesForRefresh);
    } else {
      addNewTile($tile, data.tileStatus);
    }

    Airbo.TileThumbnailMenu.initMoreBtn();
  }

  function replaceTileContent($newTile, $tilesForRefresh) {
    $tilesForRefresh.each(function(index, oldTile) {
      $(oldTile).replaceWith($newTile.clone());
    });
  }

  function addNewTile() {
    Airbo.PubSub.publish("incrementTileCounts", { status: "plan" });
    Airbo.TilesIndexLoader.resetTiles($("#plan"));
  }

  function initEvents() {
    $(newTileBtnSel).click(function(e) {
      e.preventDefault();
      var url = $(this).attr("href") || "/client_admin/tiles/new";

      tileForm = Airbo.TileFormModal;
      tileForm.init(Airbo.TileManager);
      tileForm.open(url);
    });
  }

  function initVars(thumbNail) {
    tileThumbnail = thumbNail.init(this);
  }

  function initSearch() {
    var userType = $(".explore-search-results").data().userType;
    if (userType == "user") {
      Airbo.UserTileSearch.init();
    } else {
      Airbo.TileThumbnail.init();
      Airbo.TileStatsModal.init();
    }
  }

  function forceValidationOnNew() {
    return false;
  }

  function hasAutoSave() {
    return true;
  }

  function init() {
    if ($(".explore-search").length > 0) {
      initSearch();
    } else {
      Airbo.TileThumbnail.init();
    }

    initEvents();
  }
  return {
    init: init,
    refreshOrAddTileThumb: refreshOrAddTileThumb,
    tileContainerByDataTileId: tileContainerByDataTileId,
    forceValidationOnNew: forceValidationOnNew,
    hasAutoSave: hasAutoSave
  };
})();

$(function() {
  if (
    $(".manage_tiles").length > 0 ||
    $(".explore-search-results").length > 0
  ) {
    Airbo.TileManager.init();
  }
});
