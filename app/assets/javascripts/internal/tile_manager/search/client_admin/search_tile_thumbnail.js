var Airbo = window.Airbo || {};

Airbo.SearchTileThumbnail = (function() {
  var tileManager,
      thumbnailMenu,
      thumbLinkSel = "a.tile_thumb_link_client_admin";

  function initTile(tile) {
    Airbo.SearchTileThumbnailMenu.init(tile);

    tile.find(".update_status").click(function(e){
      e.preventDefault();
      Airbo.SearchTileActions.updateStatus($(this));
    });

    tile.find(".accept").click(function(e){
      e.preventDefault();
      Airbo.TileAction.confirmAcceptance($(this));
    });

    tile.find(".edit_button a, .incomplete_button a").click(function(e){
      e.preventDefault();
      url = $(this).attr("href");

      tileForm = Airbo.TileFormModal;
      tileForm.init(Airbo.TileManager);
      tileForm.open(url);
    });

    tile.find(".destroy_button a").click(function(e){
      e.preventDefault();
      Airbo.TileAction.confirmDeletion($(this));
    });
  }

  function initEvents() {
    $("body").on("click", ".tile_container .tile_thumb_link, .tile_container .shadow_overlay", function(e){
      var self = $(this)
        ,   link
      ;

      e.preventDefault();


      //return immediately if tooltipser is triggered since we want to let it  
      //do its own handling and not do the preview
      if($(e.target).is(".pill.more") || $(e.target).is("span.dot")){
        return;
      }

      if((self).is(".tile_thumb_link")){
        link = self;
      }else{
        link = self.siblings(".tile_thumb_link");
      }

      $.ajax({
        type: "GET",
        dataType: "html",
        url: link.attr("href") ,
        success: function(data, status,xhr){
          var tilePreview = Airbo.TilePreviewModal;
          tilePreview.init();
          tilePreview.open(data);
        },

        error: function(jqXHR, textStatus, error){
          console.log(error);
        }
      });
    });
  }

  function initTiles() {
    clientAdminTiles().each(function() {
      $(this).unbind();
      initTile($(this));
    });
  }

  function init(AirboTileManager) {
    initTiles();
    initEvents();
  }

  function clientAdminTiles() {
    return $(".client_admin_tiles  .tile_container:not(.placeholder_container)");
  }

  return {
    init: init,
    initTile: initTile,
    initTiles: initTiles
  };
}());
