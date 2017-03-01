var Airbo = window.Airbo || {};

Airbo.SearchTilePreviewArrows = (function(){
  return function(){
    var tileNavRight = ".next_tile",
    tileNavLeft = ".prev_tile",
    tileNavSelector = ".button_arrow",
    tilePreview,
    defaultParams = {
      buttonSize: 100,
      offset: 10,
      afterNext: Airbo.Utils.noop,
      afterPrev: Airbo.Utils.noop,
    },
    params;

    function position() {
      sizes = tilePreview.tileContainerSizes();
      if (!sizes || sizes.left === 0 && sizes.right === 0) return;

      $(tileNavLeft).css("left", sizes.left - params.buttonSize - params.offset);
      $(tileNavRight).css("left", sizes.right + params.offset);
      $(tileNavSelector).css("display", "block");
    }

    function initEvents() {
      $(tileNavSelector).click(function(e) {
        e.preventDefault();
        var id = $(this).data('tileId');
        var path = $(this).attr('href');

        Airbo.SearchTileThumbnail.getPreview(path, id);
      });
    }

    function init(AirboTilePreview, userParams) {
      tilePreview = AirboTilePreview;
      params = $.extend(defaultParams, userParams);
    }

    return {
      init: init,
      initEvents: initEvents,
      position: position
    };
  };
}());
