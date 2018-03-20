var Airbo = window.Airbo || {};

Airbo.CopyTileToBoard = (function() {
  function copyToBoard(self, source) {
    var path = self.attr("href");
    changeCopyButtonText(self, source);
    $.post(
      path,
      {},
      function(data) {
        if (data.success) {
          copySuccess(self, source, data);
        }
      },
      "json"
    );
  }

  function changeCopyButtonText(self, source) {
    if (source === "thumbnail") {
      self.text("Copying...");
    } else if (source === "preview_modal") {
      var text = self.children(".header_text");
      text.text("Copying...");
    }
  }

  function copySuccess(self, source, data) {
    if (source === "thumbnail") {
      self.text("Copied");
      Airbo.ExploreKpis.copyTilePing(self, source);
    } else if (source === "preview_modal") {
      self.children(".header_text").text("Copied");

      $thumbnailCopyButton = thumbnailCopyButtonFromPreview(data.tile_id);
      $thumbnailCopyButton.text("Copied");
      Airbo.ExploreKpis.copyTilePing($thumbnailCopyButton, source);
    }
  }

  function thumbnailCopyButtonFromPreview(tileId) {
    return $("a[data-tile-id='" + tileId + "'].explore_copy_link");
  }

  function bindThumbnailCopyButton() {
    $(".explore_copy_link").unbind();
    $(".explore_copy_link").on("click", function(e) {
      e.preventDefault();
      copyToBoard($(this), "thumbnail");
    });
  }

  function bindTilePreviewCopyButton() {
    $(".copy_to_board").unbind();
    $(".copy_to_board" + ":not([disabled])").click(function(e) {
      e.preventDefault();
      copyToBoard($(this), "preview_modal");
    });
  }

  function bindCopyAllTiles() {
    $(".js-copy-all-tiles-button").one("click", function(e) {
      e.preventDefault();
      copyAllTiles($(this));
    });
  }

  function copyAllTiles(self) {
    Airbo.ExploreKpis.copyAllTilesPing(self);
    self.text("Copying...");

    $(".explore_copy_link").each(function(index, tile) {
      copyToBoard($(tile), "thumbnail");
    });

    self.text("Campaign Copied");
    self.addClass("disabled green");
  }

  function init() {
    bindCopyAllTiles();
    bindThumbnailCopyButton();
    bindTilePreviewCopyButton();
  }

  return {
    init: init,
    bindThumbnailCopyButton: bindThumbnailCopyButton
  };
})();

$(function() {
  if ($(".tile_wall_explore, .explore-tile_previews-show").length > 0) {
    Airbo.CopyTileToBoard.init();
  }
});
