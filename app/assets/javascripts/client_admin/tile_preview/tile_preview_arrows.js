var Airbo = window.Airbo || {};

Airbo.TilePreivewArrows = (function(){
  return function(){
    var tileNavigationSelectorLeft = ".tile_preview_container .viewer  #prev"
      , tileNavigationSelectorRight = ".tile_preview_container .viewer #next"
      , exploreTileNavLeft = ".button_arrow.prev_tile"
      , exploreTileNavRight = ".button_arrow.next_tile"
      , dummyTileNavigationSelectorLeft = ".preview_placeholder #prev"
      , dummyTileNavigationSelectorRight = ".preview_placeholder #next"
      , tileNavigationSelector = [tileNavigationSelectorLeft, tileNavigationSelectorRight, exploreTileNavLeft, exploreTileNavRight].join(", ")
      , tileNavLeft = [tileNavigationSelectorLeft, dummyTileNavigationSelectorLeft, exploreTileNavLeft].join(", ")
      , tileNavRight = [tileNavigationSelectorRight, dummyTileNavigationSelectorRight, exploreTileNavRight].join(", ")
      , tileNavSelectors = tileNavLeft + ', ' + tileNavRight
      , tilePreview
      , params = {
          buttonSize: 100,
          offset: 10
        }
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

        $.ajax({
          type: "GET",
          dataType: "html",
          url: $(this).attr("href") ,
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
      if(userParams) {
        params = userParams;
      }
    }
    return {
      init: init,
      initEvents: initEvents,
      position: position
    }
  }
}());