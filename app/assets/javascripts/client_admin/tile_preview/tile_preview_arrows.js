var Airbo = window.Airbo || {};

Airbo.TilePreivewArrows = (function(){
  return function(){
    var tileNavigationSelectorLeft = ".tile_preview_container .viewer  #prev"
      , tileNavigationSelectorRight = ".tile_preview_container .viewer #next"
      , dummyTileNavigationSelectorLeft = ".preview_placeholder #prev"
      , dummyTileNavigationSelectorRight = ".preview_placeholder #next"
      , tileNavigationSelector = tileNavigationSelectorLeft + ', ' + tileNavigationSelectorRight
      , tileNavLeft = tileNavigationSelectorLeft + ', ' + dummyTileNavigationSelectorLeft
      , tileNavRight = tileNavigationSelectorRight + ', ' + dummyTileNavigationSelectorRight
      , tileNavSelectors = tileNavLeft + ', ' + tileNavRight
      , tilePreview
    ;
    function position() {
      sizes = tilePreview.tileContainerSizes();
      if (!sizes || sizes.left == 0 && sizes.right == 0) return;

      $(tileNavLeft).css("left", sizes.left - 65);
      $(tileNavRight).css("left", sizes.right);
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
    function init(AirboTilePreview) {
      tilePreview = AirboTilePreview;
    }
    return {
      init: init,
      initEvents: initEvents,
      position: position
    }
  }
}());