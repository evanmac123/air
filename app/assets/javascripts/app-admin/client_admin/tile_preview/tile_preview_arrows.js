var Airbo = window.Airbo || {};

Airbo.TilePreviewArrows = (function() {
  var arrowButton = ".button_arrow";
  var tileNavRight = ".next_tile";
  var tileNavLeft = ".prev_tile";

  function position() {
    var sizes = Airbo.TileModalUtils.tileContainerSizes();
    var buttonSize = 40;
    var offset = 20;
    if (!sizes || (sizes.left === 0 && sizes.right === 0)) return;

    $(arrowButton).css("display", "block");
    $(tileNavLeft).css("left", sizes.left - buttonSize - offset);
    $(tileNavRight).css("left", sizes.right + offset);
  }

  function initEvents() {
    $(arrowButton).one("click", function(e) {
      e.preventDefault();
      var id = $(this).data("tileId");
      var path = $(this).attr("href");

      if ($(this).hasClass("explore_next_prev")) {
        Airbo.ExploreTileManager.getExploreTile(path, id);
      } else if ($(this)) {
        Airbo.TileThumbnail.getPreview(path, id);
      }
    });
  }

  function init() {
    position();
    initEvents();
  }

  return {
    init: init
  };
})();
