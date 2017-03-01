var Airbo = window.Airbo || {};

Airbo.ExploreTileManager = (function(){
  function initEvents() {
    $("body").on("click", ".tile_thumb_link_explore", function(e){
      e.preventDefault();
      getExploreTile($(this).attr('href'), $(this).data('tileId'));
    });
  }

  function tileContainerByDataTileId(id){
    return  $(".tile_container[data-tile-container-id=" + id + "]");
  }

  function getExploreTile(link, id, tilePreview) {
    var tile = tileContainerByDataTileId(id);
    var next = nextTile(tile).data('tileContainerId');
    var prev = prevTile(tile).data('tileContainerId');

    if (!tilePreview) {
      tilePreview = Airbo.ExploreTilePreview;
    }

    $.ajax({
      type: "GET",
      dataType: "html",
      url: link,
      data: { partial_only: true, next_tile: next, prev_tile: prev },
      success: function(data, status, xhr){
        tilePreview.init();
        tilePreview.open(data);
        initArrows(tilePreview);
      },

      error: function(jqXHR, textStatus, error){
        console.log(error);
      }
    });
  }

  function initArrows(tilePreview) {
    arrowsObj = Airbo.TilePreivewArrows();
    arrowsObj.init(tilePreview, {
      buttonSize: 40,
      offset: 20,
      afterNext: function() {
        ping("Clicked arrow to next tile");
      },
      afterPrev: function() {
        ping("Clicked arrow to previous tile");
      },
    });

    arrowsObj.initEvents();
    arrowsObj.position();
  }

  function nextTile(tile) {
    return Airbo.TileThumbnailManagerBase.nextTile(tile);
  }

  function prevTile(tile) {
    return Airbo.TileThumbnailManagerBase.prevTile(tile);
  }

  function init() {
    initEvents();
  }

  return {
    init: init,
    getExploreTile: getExploreTile
  };

}());

$(function(){
  if( $(".tile_wall_explore").length > 0 && $(".explore-search-results").length === 0) {
    Airbo.ExploreTileManager.init();
  }
});
