var Airbo = window.Airbo || {};

Airbo.CopyTileToBoard = (function(){
  function copyToBoard(self, source) {
    var path = self.attr("href");
    Airbo.ExploreKpis.copyTilePing(self, source);
    changeCopyButtonText(self, source);
    $.post(path, {},
      function(data) {
        if(data.success) {
          copySuccess(self, source, data);
        }
      },
      'json'
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
    } else if (source === "preview_modal") {
      var text = self.children(".header_text");
      text.text("Copied");
      Airbo.CopyAlert.open();
      $("a[data-tile-id='" + data.tile_id + "'].explore_copy_link").text("Copied");
    }
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
    $("#copy-all-tiles-button").one("click", function(e) {
      e.preventDefault();
      $(this).on("click", function(e) { e.preventDefault(); });
      copyAllTiles($(this));
    });
  }

  function copyAllTiles(self) {
    Airbo.ExploreKpis.copyAllTilesPing(self);
    self.text("Copying...");
    var copies = [];
    $.each($(".explore_copy_link"), function( index, selector ) {
      copyToBoard($(selector), "thumbnail");
    });

    self.text("All Tiles Copied");
    self.addClass("disabled green");
  }

  function init() {
    bindCopyAllTiles();
    bindThumbnailCopyButton();
    bindTilePreviewCopyButton();
  }

  return {
    init: init,
  };
}());

$(function(){
  if( $(".tile_wall_explore").length > 0 ) {
    Airbo.CopyTileToBoard.init();
  }
});
