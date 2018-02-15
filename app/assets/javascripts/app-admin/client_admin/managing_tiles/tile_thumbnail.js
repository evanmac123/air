var Airbo = window.Airbo || {};

Airbo.TileThumbnail = (function() {
  var thumbnailMenu;
  var curTileContainerSelector;
  var tileContainer = ".tile_container:not(.placeholder_container)";
  var buttons = tileContainer + " .tile_buttons a.button";
  var pills = tileContainer + " .tile_buttons a.pill";
  var thumbLinkSel = " .tile-wrapper a.tile_thumb_link";

  function initTileToolTipTip() {
    Airbo.TileThumbnailMenu.init();
  }

  function initActions() {
    $("body").on("click", ".tile_container .tile_buttons a", function(e) {
      e.preventDefault();
      e.stopImmediatePropagation();
      var linkSel = $(this);
      switch (linkSel.data("action")) {
        case "edit":
          handleEdit(linkSel);
          break;

        case "active":
        case "draft":
        case "plan":
        case "archive":
        case "unarchive":
        case "ignore":
        case "unignore":
        case "accept":
          handleUpdate(linkSel);
          break;

        case "delete":
          handleDelete(linkSel);
          break;
      }
    });
  }

  function handleUpdate(linkSel) {
    Airbo.TileAction.updateStatus(linkSel);
  }

  function handleDelete(linkSel) {
    Airbo.TileAction.confirmDeletion(linkSel);
  }

  function handleEdit(linkSel) {
    tileForm = Airbo.TileFormModal;
    tileForm.init(Airbo.TileManager);
    tileForm.open(linkSel.attr("href"));
  }

  function nextTile(tile) {
    return Airbo.TileThumbnailManagerBase.nextTile(tile);
  }

  function prevTile(tile) {
    return Airbo.TileThumbnailManagerBase.prevTile(tile);
  }

  function initTilePreview() {
    $("body").on(
      "click",
      ".tile_container .tile_thumb_link, .tile_container:not(.explore) .shadow_overlay",
      function(e) {
        e.preventDefault();

        var self = $(this);
        var path;

        if ($(e.target).is(".pill.more") || $(e.target).is("span.dot")) {
          return;
        }

        if (self.is(".tile_thumb_link")) {
          path = self;
        } else {
          path = self.siblings(".tile_thumb_link");
        }

        getPreview(path.attr("href"), path.data("tileId"));
      }
    );
  }

  function getPreview(path, id) {
    var tile = Airbo.TileManager.tileContainerByDataTileId(id);
    var next = nextTile(tile).data("tileContainerId");
    var prev = prevTile(tile).data("tileContainerId");

    $.ajax({
      type: "GET",
      dataType: "JSON",
      data: { partial_only: true, next_tile: next, prev_tile: prev },
      url: path,
      success: function(data, status, xhr) {
        var tilePreview = Airbo.TilePreviewModal;
        tilePreview.init();
        tilePreview.open(data.tilePreview);
      },

      error: function(jqXHR, textStatus, error) {
        console.log(error);
      }
    });
  }

  function initTiles(tileId) {
    initActions();
    initTileToolTipTip();
    initTilePreview();
  }

  function init(AirboTileManager) {
    tileManager = AirboTileManager;
    initTiles();
    return this;
  }

  return {
    init: init,
    getPreview: getPreview
  };
})();
