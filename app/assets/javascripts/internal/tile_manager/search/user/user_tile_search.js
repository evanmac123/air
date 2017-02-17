var Airbo = window.Airbo || {};

Airbo.UserTileSearch = (function(){
  function init() {
    $(".tile_thumb_link").unbind();
    $(".tile_thumb_link").on("click", function(e) {
      e.preventDefault();
      var url = $(this).attr('href');

      $.ajax({
       type: "GET",
       url: url,
       data: { id: $(this).data("tileId"), from_search: true },
       success: renderSearchTile
     });
    });
  }

  function renderSearchTile(data) {
    $('.user-results').hide();
    $('#tileViewer').append(data.tile_content);
  }

  function getNeighboringTileIds(self) {
    return Airbo.TileThumbnailManagerBase.getNeighboringTileIdsInContainer(self);
  }


  return {
    init: init
  };
}());
