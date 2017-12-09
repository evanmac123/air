var Airbo = window.Airbo || {};

Airbo.TileSearchActionObserver = (function(){
  var tileModalSelector = "#tile_preview_modal"

  function init(){
    Airbo.PubSub.subscribe("/tile-admin/tile-status-updated", function(event, payload){

      $(tileModalSelector).foundation("reveal", "close");
      payload.updatedTile.replaceAll(payload.currTile);
      Airbo.TileThumbnailMenu.initMoreBtn(payload.updatedTile.find(".pill.more"));
    });

    Airbo.PubSub.subscribe("/tile-admin/tile-copied", function(event, payload){
      //TODO shoul we show the edit tile or stay aler message?
    });
  }










  return {
    init: init
  };

})();

$(function(){
  if($(".explore-search-results-client_admin").length >0){
    Airbo.TileSearchActionObserver.init();
  }
})
