var Airbo = window.Airbo || {};

Airbo.TilePreivewArrows = (function(){
  return function(){
    var tileNavigationSelectorLeft = ".tile_preview_container .viewer  #prev"
      , tileNavigationSelectorRight = ".tile_preview_container .viewer #next"
      , exploreTileNavLeft = ".button_arrow.prev_tile"
      , exploreTileNavRight = ".button_arrow.next_tile"
      , tileNavigationSelector = [tileNavigationSelectorLeft, tileNavigationSelectorRight, exploreTileNavLeft, exploreTileNavRight].join(", ")
      , tileNavLeft = [tileNavigationSelectorLeft, exploreTileNavLeft].join(", ")
      , tileNavRight = [tileNavigationSelectorRight, exploreTileNavRight].join(", ")
      , tileNavSelectors = tileNavLeft + ', ' + tileNavRight
      , tilePreview
      , defaultParams = {
          buttonSize: 100,
          offset: 10,
          afterNext: Airbo.Utils.noop,
          afterPrev: Airbo.Utils.noop,
        }
      , params
    ;
    function position() {
      sizes = tilePreview.tileContainerSizes();
      if (!sizes || sizes.left == 0 && sizes.right == 0) return;

      $(tileNavLeft).css("left", sizes.left - params.buttonSize - params.offset);
      $(tileNavRight).css("left", sizes.right + params.offset);
      $(tileNavSelectors).css("display", "block");
    }
    function initEvents() {
      $(tileNavigationSelector).click(function(e){
        e.preventDefault();
        if( $(this)[0] == $(tileNavLeft)[0] ) {
          params.afterPrev();
        } else if( $(this)[0] == $(tileNavRight)[0] ) {
          params.afterNext();
        }
        var link = $(this);
        $.ajax({
          type: "GET",
          dataType: "html",
          url: link.attr("href"),
          data: {partial_only: true},
          success: function(data, status,xhr){
            // var tilePreview = Airbo.TilePreviewModal;
            // tilePreview.init();
            tilePreview.open(data);
            position();
          },

          error: function(jqXHR, textStatus, error){
            console.log(error);
          }
        });
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
    }
  }
}());
