var Airbo = window.Airbo || {};

Airbo.ExploreTileManager = (function(){
  function initEvents() {
    $("body").on("click", ".tile_thumb_link_explore", function(e){
      e.preventDefault();
      var tileIds = getTileIds(this);

      $.ajax({
        type: "GET",
        dataType: "html",
        url: $(this).attr("href") ,
        data: { partial_only: true, tile_ids: tileIds },
        success: function(data, status, xhr){
          var tilePreview = Airbo.ExploreTilePreview;
          tilePreview.init();
          tilePreview.open(data);
        },

        error: function(jqXHR, textStatus, error){
          console.log(error);
        }
      });
    });
  }

  function getTileIds(self) {
    var tiles = $(self).parents(".tile_container").siblings(".tile_container").andSelf();
    return $.makeArray(tiles).map(function(tile) {
      return $(tile).data("tile-container-id");
    });
  }

  function init() {
    initEvents();
  }

  return {
    init: init
  };

}());

$(function(){
  if( $(".tile_wall_explore").length > 0 ) {
    Airbo.ExploreTileManager.init();
  }
});
