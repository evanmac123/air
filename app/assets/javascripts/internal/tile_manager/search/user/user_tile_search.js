var Airbo = window.Airbo || {};

Airbo.UserTileSearch = (function(){
  function init() {
    initTileThumbnails();
  }

  function initTileThumbnails() {
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
    var scroll = $(window).scrollTop();
    $('.user-results').fadeOut();
    $(window).scrollTop(0);
    $('#tileViewer').append(data.tile_content).fadeIn('slow');
    Airbo.UserTilePreview.init(true);
    $('.back-to-search-results').on("click", function(e) {
      e.preventDefault();
      $('#tileViewer').fadeOut();
      $(this).parents('.container').remove();
      $('.user-results').fadeIn();
      $(window).scrollTop(scroll);
    });

  }

  function getNeighboringTileIds(self) {
    return Airbo.TileThumbnailManagerBase.getNeighboringTileIdsInContainer(self);
  }


  return {
    init: init
  };
}());
