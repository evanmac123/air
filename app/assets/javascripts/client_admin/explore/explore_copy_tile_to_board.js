var Airbo = window.Airbo || {};

Airbo.CopyTileToBoard = (function(){
  function copyToBoard(self, source) {

    var path = self.attr("href");

    if (source === "thumbnail") {
      self.text("Copying...");
    } else if (source === "preview_modal") {
      var text = self.children(".header_text");
      text.text("Copying...");
    }

    $.post(path, {},
      function(data) {
        if(data.success) {
          if (source === "thumbnail") {
            self.text("Copied");
          } else if (source === "preview_modal") {
            text.text("Copied");
            Airbo.CopyAlert.open();
            $("a[data-tile-id='" + data.tile_id + "'].explore_copy_link").text("Copied");
          }
        }
      },
      'json'
    );
  }

  function bindThumbnailCopyButton() {
    $(".explore_copy_link").on("click", function(e) {
      e.preventDefault();
      copyToBoard($(this), "thumbnail");
    });
  }

  function bindTilePreviewCopyButton() {
    $(".copy_to_board" + ":not([disabled])").click(function(e) {
      e.preventDefault();
      copyToBoard($(this), "preview_modal");
    });
  }

  function init() {
    bindThumbnailCopyButton();
    bindTilePreviewCopyButton();
  }

  return {
    init: init
  };
}());

$(function(){
  if( $("#tile_wall_explore").length > 0 ) {
    Airbo.CopyTileToBoard.init();
  }
});
