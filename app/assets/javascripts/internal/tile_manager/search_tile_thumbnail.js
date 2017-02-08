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
    clientAdminTiles().each(function() {
      initTile($(this));
    });

    $("body").on("click", ".tile_thumb_link_client_admin", function(e){
      e.preventDefault();
      var tileIds = Airbo.TileThumbnailManagerBase.getTileIdsInContainer(this);

      $.ajax({
        type: "GET",
        dataType: "html",
        url: $(this).attr("href") ,
        data: { partial_only: true, tile_ids: tileIds },
        success: function(data, status, xhr){
          var tilePreview = Airbo.SearchTilePreviewModal;
          tilePreview.init();
          tilePreview.open(data);
        },

        error: function(jqXHR, textStatus, error){
          console.log(error);
        }
      });
    });
  }

  function init(AirboTileManager) {
    initEvents();
  }

  function clientAdminTiles() {
    return $(".client_admin_tiles  .tile_container:not(.placeholder_container)");
  }

  return {
    init: init,
    initTile: initTile
  };
}());
