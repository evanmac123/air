var Airbo = window.Airbo ||{};
Airbo.Utils = Airbo.Utils || {};

Airbo.Utils.TileLinkHandler= (function(){
  function bindTileLink($link) {
    $link.click(function(e) {
      e.preventDefault();
      trackTileLinkClick($link);

      window.open($link.attr("href"), '_blank');
    });
  }

  function trackTileLinkClick($link) {
    var tileId = $(".tile_holder:visible").data("currentTileId");

    $.ajax({
      type: "POST",
      url: tileLinkTrackingPath(tileId),
      data: { clicked_link: $link.attr("href") },
      success: function(data, status){
        console.log(data);
      },
      error: function(xhr, status, error){
        console.log(error);
      }
    });
  }

  function tileLinkTrackingPath(tileId) {
    return "/api/tiles/" + tileId + "/tile_link_trackings";
  }

  function init(){
    $('.tile_texts_container a, .attachment-link').each(function() {
      bindTileLink($(this));
    });
  }

  return {
    init: init,
  };

}());
