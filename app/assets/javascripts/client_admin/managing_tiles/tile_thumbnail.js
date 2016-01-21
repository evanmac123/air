var Airbo = window.Airbo || {};

Airbo.TileThumbnail = (function() {
  var tileManager
    , thumbnailMenu
    , curTileContainerSelector
    , tileContainer
    , thumbLinkSel = " .tile-wrapper a.tile_thumb_link"
  ;
  function initTile(tileId) {
    curTileContainerSelector = ".tile_container[data-tile-container-id='" + tileId + "']";
    tileContainer = $(curTileContainerSelector);
    // FIXME
    // there are same events in Airbo.TilePreviewModal (edit, update, delete, duplicate)
    // reason: i want to have object, its elements and its events in one place
    thumbnailMenu.initMoreBtn(tileContainer.find(".more_button"));

    tileContainer.find(".update_status").click(function(e){
      e.preventDefault();
      e.stopPropagation();
      target = $(this);
      Airbo.TileAction.updateStatus(target);
    });

    tileContainer.find(".accept").click(function(e){
      e.preventDefault();
      e.stopPropagation();
      target = $(this);
      Airbo.TileAction.confirmAcceptance(target);
    });

    tileContainer.find(".edit_button a").click(function(e){
      e.preventDefault();
      url = $(this).attr("href");

      tileForm = Airbo.TileFormModal;
      tileForm.init(Airbo.TileManager);
      tileForm.open(url);
    });

    $("body").on("click", curTileContainerSelector + thumbLinkSel, function(e){
      e.preventDefault();
      $.ajax({
        type: "GET",
        dataType: "html",
        url: $(this).attr("href") ,
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
  function initEvents(){
    tileIds = $(".tile_container:not(.placeholder_container)").map(function(){
      return $(this).data("tile-container-id");
    });
    uniqueTileIds = jQuery.unique(tileIds);

    uniqueTileIds.each(function(){
      initTile( this );
    });
  }
  function init(AirboTileManager) {
    tileManager = AirboTileManager;
    thumbnailMenu = Airbo.TileThumbnailMenu.init(tileManager);
    initEvents();
    return this;
  }
  return {
    init: init,
    initTile: initTile
  }
}());
